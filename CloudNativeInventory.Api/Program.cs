using Azure.Identity;
using CloudNativeInventory.Api.Data;
using CloudNativeInventory.Api.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Diagnostics.HealthChecks;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers();
builder.Services.AddOpenApi();

builder.Services.AddHealthChecks()
    .AddCheck<HealthCheckz>("self");

builder.Services.AddDbContext<InventoryDbContext>(options =>
    options.UseInMemoryDatabase("InventoryDb"));

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    // this is especially important to be run in dev mode only, otherwise we will expose endpoints, response details etc!
    app.MapOpenApi();
}

app.UseAuthorization();

app.MapControllers();

app.MapHealthChecks("/health/live");

app.Run();
using Microsoft.Extensions.Diagnostics.HealthChecks;

public class HealthCheckz : IHealthCheck
{
    public Task<HealthCheckResult> CheckHealthAsync(HealthCheckContext context, CancellationToken cancellationToken = default)
    {
        var isHealthy = true;
        var responseString = $"Healthy  =  {isHealthy}";
 
        return isHealthy 
        ? Task.FromResult(HealthCheckResult.Healthy(responseString)) 
        : Task.FromResult(new HealthCheckResult(context.Registration.FailureStatus, responseString));

    }
}
# ADR-001: Host the application in Azure Container Apps

## Status

Accepted

## Context

The application requires a production hosting environment capable of running a containerized ASP.NET Core API while integrating with the rest of the Azure ecosystem.

The main alternatives considered were Azure App Service and Azure Container Apps.

This decision was not completely obvious, because both services share many of the features needed for this project. Both work with Managed Identity, Key Vault, monitoring, logging etc.

However in the end, Azure Container Apps was chosen. This decision was based on which platform aligned most naturally with the current state
of the project, and the potential long-term direction of the project.

## Decision

The application will be hosted using Azure Container Apps.

## Reasoning

Two primary reasons led to this decision.



### 1. Better alignment with a future microservice architecture

Although the current project consists of a single Inventory API, it has been designed with future expansion in mind.

If the project were to evolve into a larger e-commerce platform, the application would be separated into multiple independently deployable services, such as Inventory, Orders, Payments, Notifications, and Authentication.

ACA has [built-in features for microservices](https://learn.microsoft.com/en-us/azure/architecture/microservices/design/compute-options), which makes the compute platform more naturally suited for a future microservice implementation.

Azure Container Apps also aligns well with possible event-driven workloads. For example, Azure Functions could later be introduced for background tasks such as queue processing, scheduled jobs, notifications, or asynchronous integration work. 

While similar outcomes could also be achieved with App Service and separate Azure Functions, Container Apps provides a more unified path for running APIs, containerized background jobs, and event-driven components within the same platform model.
So while the project does not currently require a microservice architecture or Azure Functions, choosing a platform that aligns with that potential future direction reduces architectural "hick-ups" if that transition were made.




### 2. Scale-to-zero

Since this project currently serves as a demonstration application, it is expected to receive relatively little traffic.

Azure Container Apps supports scale-to-zero, allowing the application to consume virtually no compute resources while idle and automatically start when requests arrive.

For a low-traffic demonstration project, this provides a practical cost optimization.

Although this was not the primary reason for choosing Azure Container Apps, it was considered a valuable benefit given the current scope of the project.
The trade-off is that cold starts may occur after periods of inactivity, because the application may need to start again when a new request arrives.
In a scenario where the API would require stricter latency requirements and cosistent responsiveness, the issue with cold starts could be mitigated by things like 
increasing the minimum replica count, using warm-up traffic and lightweight health checks.


## Consequences

### Positive

* Better alignment with cloud-native application design.
* Supports future expansion into independently deployable services.
* Cost-efficient hosting for low traffic through scale-to-zero.
* Integration with Azure Container Registry, Managed Identity, Azure Key Vault, GitHub Actions, and Azure Monitor/Log Analytics. Application-level telemetry can also be added through Application Insights/OpenTelemetry instrumentation.

### Negative

* Cold starts may occur after periods of inactivity due to scale-to-zero.

## Alternatives Considered

### Azure App Service

Azure App Service would have been a valid option.

It supports web APIs, supports containers, integrates with Azure services, and works well with production applications.
However, for this project, Azure App Service felt slightly less aligned with the potential future implementations.

### Azure Kubernetes Service

Azure Kubernetes Service would also work, but it would be overkill for the current scope and deadline.
AKS gives more control, for a small Inventory API, that complexity would not provide enough value.












var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// ⭐ CONFIGURACIÓN PARA DOCKER
// Escuchar en todas las interfaces en puerto 8080
builder.WebHost.ConfigureKestrel(options =>
{
    options.ListenAnyIP(8080);
});

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

// ⭐ COMENTAR HTTPS REDIRECT PARA DOCKER/RENDER
// Render maneja SSL en su load balancer
// app.UseHttpsRedirection();

// ⭐ HEALTH CHECK ENDPOINT (CRÍTICO PARA RENDER)
app.MapGet("/health", () => Results.Ok(new 
{ 
    status = "healthy", 
    timestamp = DateTime.UtcNow,
    environment = app.Environment.EnvironmentName
}))
.WithName("HealthCheck")
.WithOpenApi();

// Endpoint original de weatherforecast
var summaries = new[]
{
    "Freezing", "Bracing", "Chilly", "Cool", "Mild", "Warm", "Balmy", "Hot", "Sweltering", "Scorching"
};

app.MapGet("/weatherforecast", () =>
{
    var forecast = Enumerable.Range(1, 5).Select(index =>
        new WeatherForecast
        (
            DateOnly.FromDateTime(DateTime.Now.AddDays(index)),
            Random.Shared.Next(-20, 55),
            summaries[Random.Shared.Next(summaries.Length)]
        ))
        .ToArray();
    return forecast;
})
.WithName("GetWeatherForecast")
.WithOpenApi();

// ⭐ LOG DE INICIO
app.Logger.LogInformation("🚀 MyApi starting on {Environment} at {Time}", 
    app.Environment.EnvironmentName, 
    DateTime.UtcNow);

app.Run();

record WeatherForecast(DateOnly Date, int TemperatureC, string? Summary)
{
    public int TemperatureF => 32 + (int)(TemperatureC / 0.5556);
}
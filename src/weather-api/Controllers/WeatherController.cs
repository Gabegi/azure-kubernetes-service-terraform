using Microsoft.AspNetCore.Mvc;

namespace WeatherApi.Controllers;

[ApiController]
[Route("api/[controller]")]
public class WeatherController : ControllerBase
{
    private static readonly string[] Summaries = new[]
    {
        "Freezing", "Bracing", "Chilly", "Cool", "Mild",
        "Warm", "Balmy", "Hot", "Sweltering", "Scorching"
    };

    [HttpGet]
    public IActionResult Get()
    {
        var forecast = Enumerable.Range(1, 5).Select(index => new
        {
            date = DateOnly.FromDateTime(DateTime.Now.AddDays(index)),
            temperatureC = Random.Shared.Next(-20, 55),
            summary = Summaries[Random.Shared.Next(Summaries.Length)]
        })
        .ToArray();

        return Ok(forecast);
    }

    [HttpGet("{city}")]
    public IActionResult GetByCity(string city)
    {
        var temperature = Random.Shared.Next(-20, 55);
        return Ok(new
        {
            city = city,
            temperatureC = temperature,
            temperatureF = 32 + (int)(temperature / 0.5556),
            summary = Summaries[Random.Shared.Next(Summaries.Length)],
            timestamp = DateTime.UtcNow
        });
    }
}

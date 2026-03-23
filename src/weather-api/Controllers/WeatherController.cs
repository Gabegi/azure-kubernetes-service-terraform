using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using WeatherApi.Data;
using WeatherApi.Models;

namespace WeatherApi.Controllers;

[ApiController]
[Route("api/[controller]")]
public class WeatherController : ControllerBase
{
    private readonly WeatherDbContext _context;

    public WeatherController(WeatherDbContext context)
    {
        _context = context;
    }

    [HttpGet]
    public async Task<IActionResult> GetWeather()
    {
        var weather = await _context.WeatherRecords.ToListAsync();
        return Ok(weather);
    }

    [HttpPost]
    public async Task<IActionResult> SaveWeather([FromBody] WeatherData data)
    {
        Console.WriteLine("*** POST called!");
        Console.WriteLine($"*** Data received: City={data?.City}, Temp={data?.Temperature}");

        if (data == null)
        {
            Console.WriteLine("*** ERROR: data is NULL!");
            return BadRequest("Data is null");
        }

        data.RecordedAt = DateTime.UtcNow;
        _context.WeatherRecords.Add(data);

        Console.WriteLine("*** About to save...");
        await _context.SaveChangesAsync();
        Console.WriteLine("*** Saved successfully!");

        return CreatedAtAction(nameof(GetWeather), new { id = data.Id }, data);
    }
}

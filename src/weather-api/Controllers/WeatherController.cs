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
        data.RecordedAt = DateTime.UtcNow;
        _context.WeatherRecords.Add(data);
        await _context.SaveChangesAsync();
        return CreatedAtAction(nameof(GetWeather), new { id = data.Id }, data);
    }
}

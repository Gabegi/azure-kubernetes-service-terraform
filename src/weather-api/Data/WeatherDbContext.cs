using Microsoft.EntityFrameworkCore;
using WeatherApi.Models;

namespace WeatherApi.Data;

public class WeatherDbContext : DbContext
{
    public WeatherDbContext(DbContextOptions<WeatherDbContext> options)
        : base(options) { }

    public DbSet<WeatherData> WeatherRecords { get; set; }
}

namespace WeatherApi.Models;

public class WeatherData
{
    public int Id { get; set; }
    public string City { get; set; } = string.Empty;
    public int Temperature { get; set; }
    public DateTime RecordedAt { get; set; }
}

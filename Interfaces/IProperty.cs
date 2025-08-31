using realEstate1.Models;

namespace realEstate1.Interfaces
{
	public interface IProperty
	{
		Task<IEnumerable<Property>> GetAllPropertiesAsync();
		Task<Property?> GetPropertyByIdAsync(int id);
		Task CreatePropertyAsync(Property property , List<IFormFile> imageFiles);
		Task UpdatePropertyAsync(Property property);
		Task<bool> DeletePropertyAsync(int id);
		Task<bool> PropertyExistsAsync(int id);
		Task<List<DateTime>> GetBookedDatesAsync(int propertyId);
		Task<IEnumerable<Property>> GetPropertiesByCategoryAsync(string category);
	}
}

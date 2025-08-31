using Microsoft.EntityFrameworkCore;
using realEstate1.Data;
using realEstate1.Interfaces;
using realEstate1.Models;

namespace realEstate1.Services
{
	public class PropertyService : IProperty
	{
		private readonly MyAppDbContext _context;
		private readonly IImages _imageService;

		public PropertyService(MyAppDbContext context , IImages imageService)
		{
			_context = context;
			_imageService = imageService;
		}

	
		public async Task CreatePropertyAsync(Property property , List<IFormFile> imageFiles)
		{
			await _context.Properties.AddAsync(property);
			await _context.SaveChangesAsync();

			if(imageFiles != null && imageFiles.Count > 0)
			{
				_imageService.SaveImages(property.PropertyID , imageFiles);
			}
		}

		
		public async Task<Property?> GetPropertyByIdAsync(int id)
		{
			return await _context.Properties
				.Include(p => p.PropertiesImages)
				.FirstOrDefaultAsync(m => m.PropertyID == id);
		}

		public async Task<bool> DeletePropertyAsync(int id)
		{
			var property = await _context.Properties.FindAsync(id);

			if(property == null)
				return false;

			_context.Properties.Remove(property);
			await _context.SaveChangesAsync();
			return true;
		}

		
		public async Task<List<DateTime>> GetBookedDatesAsync(int propertyId)
		{
			var bookedDates = new List<DateTime>();

			var leases = await _context.Leases
				.Where(l => l.PropertyID == propertyId)
				.ToListAsync();

			foreach(var lease in leases)
			{
				for(var date = lease.StartDate ; date <= lease.EndDate ; date = date.AddDays(1))
				{
					bookedDates.Add(date);
				}
			}

			return bookedDates;
		}

		
		public async Task<IEnumerable<Property>> GetAllPropertiesAsync()
		{
			return await _context.Properties
				.Include(p => p.PropertiesImages)
				.ToListAsync();
		}


		public async Task<bool> PropertyExistsAsync(int id)
		{
			return await _context.Properties.AnyAsync(e => e.PropertyID == id);
		}

		public async Task UpdatePropertyAsync(Property property)
		{
			_context.Update(property);
			await _context.SaveChangesAsync();
		}

		public async Task<IEnumerable<Property>> GetPropertiesByCategoryAsync(string category)
		{
			return await _context.Properties
				.Include(p => p.PropertiesImages)
				.Where(p => p.Type == category)
				.ToListAsync();
		}
	}
}

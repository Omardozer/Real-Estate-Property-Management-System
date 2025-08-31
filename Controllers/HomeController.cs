using Microsoft.AspNetCore.Mvc;
using realEstate1.Interfaces;
using realEstate1.Models;
using System.Diagnostics;

namespace realEstate1.Controllers
{
	public class HomeController : Controller
	{
		private readonly ILogger<HomeController> _logger;
		private readonly IProperty _propertyService;

		public HomeController(ILogger<HomeController> logger , IProperty propertyService)
		{
			_logger = logger;
			_propertyService = propertyService;
		}

		[HttpGet]
		public async Task<IActionResult> Index()
		{
			var properties = await _propertyService.GetAllPropertiesAsync();
			return View(properties);
		}

		public IActionResult Privacy()
		{
			return View();
		}

		[ResponseCache(Duration = 0 , Location = ResponseCacheLocation.None , NoStore = true)]
		public IActionResult Error()
		{
			return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
		}

		[HttpPost]
		public async Task<IActionResult> GetProperties(
			string? search ,
			string? category ,
			int? minPrice ,
			int? maxPrice ,
			int? bedrooms ,
			int? bathrooms)
		{
			var properties = await _propertyService.GetAllPropertiesAsync();

			if(!string.IsNullOrWhiteSpace(search))
				properties = properties.Where(p => p.Address.Contains(search , StringComparison.OrdinalIgnoreCase));

			if(!string.IsNullOrWhiteSpace(category))
				properties = properties.Where(p => p.Type.Equals(category , StringComparison.OrdinalIgnoreCase));

			if(minPrice.HasValue)
				properties = properties.Where(p => p.PricePerDay >= minPrice.Value);

			if(maxPrice.HasValue)
				properties = properties.Where(p => p.PricePerDay <= maxPrice.Value);

			if(bedrooms.HasValue)
				properties = properties.Where(p => p.Bedrooms == bedrooms.Value);

			if(bathrooms.HasValue)
				properties = properties.Where(p => p.Bathrooms == bathrooms.Value);

			return PartialView("_PropertyListPartial" , properties.ToList());
		}

		[HttpPost]
		public IActionResult RentProperty(int propertyId)
		{
			return RedirectToAction("Create" , "Lease" , new { propertyId });
		}
	}
}

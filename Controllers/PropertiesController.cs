using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using Microsoft.EntityFrameworkCore.Metadata.Internal;
using realEstate1.Interfaces;
using realEstate1.Models;
using System;
using System.Linq;
using System.Security.Cryptography;
using System.Threading.Tasks;

namespace realEstate1.Controllers
{
	public class PropertiesController : Controller
	{
		private readonly IProperty _propertyService;
		private readonly IPayment _paymentService;
		private readonly ILease _leaseService;
		private readonly UserManager<ApplicationUser> _userManager;

		public PropertiesController(
			IProperty propertyService ,
			IPayment paymentService ,
			ILease leaseService ,
			UserManager<ApplicationUser> userManager)
		{
			_propertyService = propertyService;
			_paymentService = paymentService;
			_leaseService = leaseService;
			_userManager = userManager;
		}

		[Authorize(Roles = "User,Admin")]
		[HttpGet]
		public async Task<IActionResult> Index()
		{
			var properties = await _propertyService.GetAllPropertiesAsync();
			return View(properties);
		}

		[HttpGet]
		public async Task<IActionResult> Details(int id)
		{
			var property = await _propertyService.GetPropertyByIdAsync(id);
			if(property == null) return NotFound();
			return View(property);
		}


		[HttpGet]
		[Authorize(Roles = "User")]
		public IActionResult Create()
		{
			return View();
		}

		[HttpPost]
		[Authorize(Roles = "User")]
		[ValidateAntiForgeryToken]
		public async Task<IActionResult> Create(Models.Property property , List<IFormFile> imageFiles)
		{
			

			var user = await _userManager.GetUserAsync(User);
			var userId = user.Id;
			property.OwnerID = userId;

			
			if(!ModelState.IsValid) return View(property);

			await _propertyService.CreatePropertyAsync(property , imageFiles);
			return RedirectToAction("Index" , "Home");
		}

		[HttpGet]
		[Authorize(Roles = "User,Admin")]
		public async Task<IActionResult> Edit(int id)
		{
			var property = await _propertyService.GetPropertyByIdAsync(id);
			if(property == null) return NotFound();

			return View(property);
		}

		[HttpPost]
		[Authorize(Roles = "User,Admin")]
		[ValidateAntiForgeryToken]
		public async Task<IActionResult> Edit(
			int id ,
			[Bind("PropertyID,Address,Type,Bedrooms,Bathrooms,PricePerDay,Description")]
			Models.Property input)
		{
			if(id != input.PropertyID) return NotFound();
			if(!ModelState.IsValid) return View(input);

			var existing = await _propertyService.GetPropertyByIdAsync(id);
			if(existing == null) return NotFound();

			existing.Address = input.Address;
			existing.Type = input.Type;
			existing.Bedrooms = input.Bedrooms;
			existing.Bathrooms = input.Bathrooms;
			existing.PricePerDay = input.PricePerDay;
			existing.Description = input.Description;
			

			await _propertyService.UpdatePropertyAsync(existing);
			return RedirectToAction(nameof(Index));
		}

		[Authorize(Roles = "User,Admin")]
		[HttpGet]
		public async Task<IActionResult> Delete(int id)
		{
			var property = await _propertyService.GetPropertyByIdAsync(id);
			if(property == null) return NotFound();
			return View(property);
		}

		[HttpPost, ActionName("Delete")]
		[Authorize(Roles = "User,Admin")]
		[ValidateAntiForgeryToken]
		public async Task<IActionResult> DeleteConfirmed(int id)
		{
			var success = await _propertyService.DeletePropertyAsync(id);
			if(!success) return NotFound();
			return RedirectToAction(nameof(Index));
		}

		[Authorize(Roles = "User,Admin")]
		[HttpGet]

		public async Task<IActionResult> Rent(int id)
		{
			var property = await _propertyService.GetPropertyByIdAsync(id);
			if(property == null) return NotFound();

			var bookedDates = await _propertyService.GetBookedDatesAsync(id);
			var model = new RentViewModel
			{
				PropertyId = id ,
				terms = property.terms ,
				OwnerId = property.OwnerID ,
				Address = property.Address ,
				Description = property.Description,
				PricePerDay = property.PricePerDay,
				StartDate = DateTime.Today ,
				EndDate = DateTime.Today.AddDays(1)
			};

			ViewBag.BookedDates = bookedDates.Select(d => d.ToString("yyyy-MM-dd")).ToList();
			return View(model);
		}
		[HttpPost]
		[Authorize(Roles = "User")]
		public async Task<IActionResult> Rent(RentViewModel model)
		{
			var user = await _userManager.GetUserAsync(User);
			var userId = user.Id;
			var lease = await _leaseService.CreateLeaseAsync(model.PropertyId , model.OwnerId, userId , model.StartDate , model.EndDate , model.terms);
			var Amount = await _leaseService.CalculatePaymentAmountAsync(model.PropertyId, model.StartDate , model.EndDate);
		
			return RedirectToAction("Payment" ,"Payment" ,new { leaseId = lease.LeaseID , amount = Amount });
		}

		[Authorize(Roles = "User,Admin")]
		[HttpGet]
		public async Task<IActionResult> GetPropertiesByCategory(string category)
		{
			if(string.IsNullOrWhiteSpace(category))
				return RedirectToAction(nameof(Index));

			ViewBag.Category = category;
			var properties = await _propertyService.GetPropertiesByCategoryAsync(category);
			return View(properties);
		}
		[Authorize(Roles = "User,Admin")]

		private async Task<bool> PropertyExists(int id)
			=> await _propertyService.PropertyExistsAsync(id);
	}
}
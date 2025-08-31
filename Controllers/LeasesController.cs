using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using realEstate1.Interfaces;
using realEstate1.Models;

namespace realEstate1.Controllers
{
	public class LeasesController : Controller
	{
		private readonly ILease _leaseService;

		public LeasesController(ILease leaseService)
		{
			_leaseService = leaseService;
		}

		[Authorize(Roles = "User,Admin")]

		public async Task<IActionResult> Index()
		{
			var leases = await _leaseService.GetAllLeasesAsync();

			var leaseViewModels = leases.Select(l => new LeaseViewModel
			{
				LeaseID = l.LeaseID ,
				PropertyAddress = l.Property.Address ,
				TenantName = l.Tenant.Name ,
				StartDate = l.StartDate ,
				EndDate = l.EndDate ,
				Terms = l.Terms
			}).ToList();

			return View(leaseViewModels);
		}

		[Authorize(Roles = "User,Admin")]

		public async Task<IActionResult> Edit(int? id)
		{
			if(id == null) return NotFound();

			var lease = await _leaseService.GetLeaseByIdAsync(id.Value);
			if(lease == null) return NotFound();

			var leaseViewModel = new LeaseViewModel
			{
				LeaseID = lease.LeaseID ,
				PropertyAddress = lease.Property.Address ,
				TenantName = lease.Tenant.Name ,
				StartDate = lease.StartDate ,
				EndDate = lease.EndDate ,
				Terms = lease.Terms
			};

			return View(leaseViewModel);
		}

		[Authorize(Roles = "User,Admin")]
		[HttpPost]
		[ValidateAntiForgeryToken]
		public async Task<IActionResult> Edit(int id , LeaseViewModel leaseViewModel)
		{
			if(id != leaseViewModel.LeaseID) return NotFound();

			if(leaseViewModel.EndDate <= leaseViewModel.StartDate)
			{
				ModelState.AddModelError("EndDate" , "End date must be after start date.");
			}

			if(!ModelState.IsValid) return View(leaseViewModel);

			var result = await _leaseService.UpdateLeaseAsync(id , leaseViewModel);

			if(!result) return NotFound();

			return RedirectToAction(nameof(Index));
		}

		[Authorize(Roles = "User,Admin")]

		public async Task<IActionResult> Delete(int? id)
		{
			if(id == null) return NotFound();

			var lease = await _leaseService.GetLeaseByIdAsync(id.Value);
			if(lease == null) return NotFound();

			var leaseViewModel = new LeaseViewModel
			{
				LeaseID = lease.LeaseID ,
				PropertyAddress = lease.Property.Address ,
				TenantName = lease.Tenant.Name ,
				StartDate = lease.StartDate ,
				EndDate = lease.EndDate ,
				Terms = lease.Terms
			};

			return View(leaseViewModel);
		}
		[Authorize(Roles = "User,Admin")]

		[HttpPost, ActionName("Delete")]
		[ValidateAntiForgeryToken]
		public async Task<IActionResult> DeleteConfirmed(int id)
		{
			var result = await _leaseService.RemoveLeaseAsync(id);
			if(!result) return NotFound();

			return RedirectToAction(nameof(Index));
		}
	}
}

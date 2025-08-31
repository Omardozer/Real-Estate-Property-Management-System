using Microsoft.AspNetCore.Mvc;
using realEstate1.Interfaces;
using realEstate1.Models;

namespace realEstate1.Controllers
{
	public class PaymentController : Controller
	{
		private readonly ILease _leaseService;
		private readonly IPayment _paymentService;

		public PaymentController(IPayment paymentService , ILease leaseService)
		{
			_leaseService = leaseService;
			_paymentService = paymentService;
		}

		[HttpGet]
		public async Task<IActionResult> Payment(int leaseId , decimal amount)
		{
			var lease = await _leaseService.GetLeaseByIdAsync(leaseId);
			if(lease == null) return NotFound();

			var model = new PaymentViewModel
			{
				LeaseID = leaseId ,
				Amount = amount
			};

			return View(model);
		}

		[HttpPost]
		[ValidateAntiForgeryToken]
		public async Task<IActionResult> ProcessPayment(PaymentViewModel model)
		{
			if(!ModelState.IsValid)
				return View("Payment" , model);

			try
			{
				var (success, transactionId) = await _paymentService.ProcessPaymentAsync(model);

				if(!success)
				{
					ModelState.AddModelError("" , "Payment failed. Please try again.");
					return View("Payment" , model);
				}

				TempData["PaymentSuccess"] = "Payment completed successfully!";
				return RedirectToAction("Index" , "Home");
			}
			catch(Exception ex)
			{
				ModelState.AddModelError("" , "An error occurred while processing payment.");
				return View("Payment" , model);
			}
		}
	}
}

using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using realEstate1.Models;
using System;
using System.Threading.Tasks;

namespace realEstate1.Controllers
{
	[AllowAnonymous]
	public class AccountController : Controller
	{
		private readonly UserManager<ApplicationUser> _userManager;
		private readonly SignInManager<ApplicationUser> _signInManager;
		private readonly ILogger<AccountController> _logger;

		public AccountController(
			UserManager<ApplicationUser> userManager ,
			SignInManager<ApplicationUser> signInManager ,
			ILogger<AccountController> logger)
		{
			_userManager = userManager;
			_signInManager = signInManager;
			_logger = logger;
		}

		[HttpGet]
		public IActionResult Register(string? returnUrl = null)
		{
			ViewData["ReturnUrl"] = returnUrl;
			return View();
		}

		[HttpPost]
		[AllowAnonymous]
		public async Task<IActionResult> Register(Register model)
		{
			if(ModelState.IsValid)
			{
				var user = new ApplicationUser
				{
					UserName = model.UserName ,
					Email = model.Email ,
					Name = model.Name ,
					PhoneNumber = model.PhoneNumber,
				};

				var result = await _userManager.CreateAsync(user , model.Password);

				if(result.Succeeded)
				{
					await _userManager.AddToRoleAsync(user , "User");

					await _signInManager.SignInAsync(user , isPersistent: false);
					return RedirectToAction("Index" , "Home");
				}

				foreach(var error in result.Errors)
					ModelState.AddModelError("" , error.Description);
			}

			return View(model);
		}

		[HttpGet]
		public IActionResult Login(string? returnUrl = null)
		{
			ViewData["ReturnUrl"] = returnUrl;
			return View();
		}

		// POST: /Account/Login
		[HttpPost]
		[ValidateAntiForgeryToken]
		public async Task<IActionResult> Login(Login model , string? returnUrl = null)
		{
			if(!ModelState.IsValid)
			{
				ViewData["ReturnUrl"] = returnUrl;
				return View(model);
			}

			var user = await _userManager.FindByNameAsync(model.UserName);

			var result = await _signInManager.PasswordSignInAsync(
				userName: model.UserName ,
				password: model.Password ,
				isPersistent: false ,
				lockoutOnFailure: false);
			bool valid = await _userManager.CheckPasswordAsync(user , "NewPassword123!");
			if(result.Succeeded)
			{
				_logger.LogInformation("User logged in.");
				return LocalRedirect(ResolveReturnUrl(returnUrl));
			}

			ModelState.AddModelError(string.Empty , "Invalid login attempt.");
			ViewData["ReturnUrl"] = returnUrl;
			return View(model);
		}

		[Authorize]
		[HttpPost]
		[ValidateAntiForgeryToken]
		public async Task<IActionResult> Logout()
		{
			await _signInManager.SignOutAsync();
			_logger.LogInformation("User logged out.");
			return RedirectToAction(nameof(HomeController.Index) , "Home");
		}

		private string ResolveReturnUrl(string? returnUrl)
			=> Url.IsLocalUrl(returnUrl) ? returnUrl! : Url.Content("~/");
	}
}

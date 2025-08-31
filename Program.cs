using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using realEstate1.Data;
using realEstate1.Interfaces;
using realEstate1.Models;
using realEstate1.Services;

var builder = WebApplication.CreateBuilder(args);

var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");
builder.Services.AddDbContext<MyAppDbContext>(options =>
	options.UseSqlServer(connectionString));

builder.Services.AddScoped<IImages , ImageService>();
builder.Services.AddScoped<IProperty , PropertyService>();
builder.Services.AddScoped<IPayment , PaymentService>();
builder.Services.AddScoped<ILease , LeaseService>();

builder.Services.AddIdentity<ApplicationUser , IdentityRole<Guid>>(options =>
{
	options.Password.RequireDigit = true;
	options.Password.RequireLowercase = true;
	options.Password.RequireUppercase = true;
	options.Password.RequiredLength = 6;
	options.Password.RequireNonAlphanumeric = false;
	options.User.RequireUniqueEmail = true;
	options.SignIn.RequireConfirmedAccount = false;
})
.AddEntityFrameworkStores<MyAppDbContext>()
.AddDefaultTokenProviders();

builder.Services.ConfigureApplicationCookie(options =>
{
	options.LoginPath = "/Account/Login";
	options.LogoutPath = "/Account/Logout";
	options.AccessDeniedPath = "/Account/AccessDenied";
	options.ExpireTimeSpan = TimeSpan.FromMinutes(60);
	options.SlidingExpiration = true;
});

builder.Services.AddControllersWithViews();

builder.Services.AddAuthorization(options =>
{
	options.AddPolicy("UserPolicy" , policy => policy.RequireRole("User"));
});

var app = builder.Build();

if(!app.Environment.IsDevelopment())
{
	app.UseExceptionHandler("/Home/Error");
	app.UseHsts();
}

app.UseHttpsRedirection();
app.UseStaticFiles();

app.UseRouting();

app.UseAuthentication();
app.UseAuthorization();

app.MapControllerRoute(
	name: "default" ,
	pattern: "{controller=Home}/{action=Index}/{id?}");

using(var scope = app.Services.CreateScope())
{
	var roleManager = scope.ServiceProvider.GetRequiredService<RoleManager<IdentityRole<Guid>>>();
	var userManager = scope.ServiceProvider.GetRequiredService<UserManager<ApplicationUser>>();

	string[] roles = { "Admin" , "User" };
	foreach(var role in roles)
	{
		if(!await roleManager.RoleExistsAsync(role))
			await roleManager.CreateAsync(new IdentityRole<Guid>(role));
	}
	
}

app.Run();

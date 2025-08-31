using Microsoft.EntityFrameworkCore;
using realEstate1.Data;
using realEstate1.Interfaces;
using realEstate1.Models;

namespace realEstate1.Services
{
	public class LeaseService : ILease
	{
		private readonly MyAppDbContext _context;

		public LeaseService(MyAppDbContext context)
		{
			_context = context;
		}

		public async Task<Lease> CreateLeaseAsync(int propertyId , Guid ownerId , Guid tenantId , DateTime startDate , DateTime endDate , string terms)
		{
			
			var lease = new Lease
			{
				PropertyID = propertyId ,
				TenantID = tenantId ,
				OwnerID= ownerId ,
				StartDate = startDate ,
				EndDate = endDate ,
				Terms = terms
			};

			_context.Leases.Add(lease);
			await _context.SaveChangesAsync();
			return lease;
		}

		public async Task<bool> IsPropertyAvailableAsync(int propertyId , DateTime startDate , DateTime endDate)
		{
			var existingLeases = await _context.Leases
				.Where(l => l.PropertyID == propertyId &&
							(l.StartDate < endDate && l.EndDate > startDate))
				.ToListAsync();

			return existingLeases.Count == 0; 
		}

		public async Task<decimal> CalculatePaymentAmountAsync(int propertyId , DateTime startDate , DateTime endDate)
		{
			var property = await _context.Properties.FirstOrDefaultAsync(p => p.PropertyID == propertyId);
			if(property != null)
			{
				int numberOfDays = (endDate - startDate).Days;
				return numberOfDays * property.PricePerDay;
			}

			throw new Exception("Property not found.");
		}

		public async Task<IEnumerable<Lease>> GetAllLeasesAsync()
		{
			return await _context.Leases
				.Include(l => l.Property)
				.Include(l => l.Tenant)
				.Include(l => l.Owner)
				.ToListAsync();
		}

		public async Task<Lease?> GetLeaseByIdAsync(int id)
		{
			return await _context.Leases
				.Include(l => l.Property)
				.Include(l => l.Owner)
				.Include(l => l.Tenant)
				.FirstOrDefaultAsync(m => m.LeaseID == id);
		}

		public async Task<bool> UpdateLeaseAsync(int id , LeaseViewModel model)
		{
			var lease = await _context.Leases.FindAsync(id);
			if(lease == null) return false;

			lease.StartDate = model.StartDate;
			lease.EndDate = model.EndDate;
			lease.Terms = model.Terms;

			_context.Leases.Update(lease);
			await _context.SaveChangesAsync();
			return true;
		}

		public async Task<bool> RemoveLeaseAsync(int id)
		{
			var lease = await _context.Leases.FindAsync(id);
			if(lease == null) return false;

			_context.Leases.Remove(lease);
			await _context.SaveChangesAsync();
			return true;
		}
	}
}

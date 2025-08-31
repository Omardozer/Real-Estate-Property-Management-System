using realEstate1.Models;

namespace realEstate1.Interfaces
{
    public interface ILease
    {
		Task<Lease> CreateLeaseAsync(int propertyId , Guid ownerId ,Guid tenantId , DateTime startDate , DateTime endDate , string terms);
		Task<decimal> CalculatePaymentAmountAsync(int propertyId , DateTime startDate , DateTime endDate);
		Task<IEnumerable<Lease>> GetAllLeasesAsync();
		Task<Lease?> GetLeaseByIdAsync(int id);
		Task<bool> UpdateLeaseAsync(int id , LeaseViewModel model);
		Task<bool> RemoveLeaseAsync(int id);
	}
}

using realEstate1.Models;

namespace realEstate1.Interfaces
{
    public interface IPayment
    {
		Task<(bool Success, string TransactionId)> ProcessPaymentAsync(PaymentViewModel model);
		Task SavePaymentAsync(Payment payment);

		Task<List<Payment>> GetPaymentsByLeaseAsync(int leaseId);

	}
}


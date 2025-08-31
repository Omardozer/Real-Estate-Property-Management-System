using Microsoft.EntityFrameworkCore;
using realEstate1.Data;
using realEstate1.Interfaces;
using realEstate1.Models;

namespace realEstate1.Services
{
    public class PaymentService : IPayment
    {
        private readonly MyAppDbContext _context;

        public PaymentService(MyAppDbContext context)
        {
            _context = context;
        }

        // Simulate payment processing via external gateway
        public async Task<(bool Success, string TransactionId)> ProcessPaymentAsync(PaymentViewModel model)
        {
           

            var transactionId = Guid.NewGuid().ToString();

            var payment = new Payment
            {
                LeaseID = model.LeaseID,
                Amount = model.Amount,
                Date = DateTime.UtcNow,
                Status = "Completed",
                TransactionId = transactionId,
                PaymentMethod = "CreditCard"
            };

            await SavePaymentAsync(payment);

            return (true, transactionId);
        }

        public async Task SavePaymentAsync(Payment payment)
        {
            await _context.Payments.AddAsync(payment);
            await _context.SaveChangesAsync();
        }

        public async Task<List<Payment>> GetPaymentsByLeaseAsync(int leaseId)
        {
            return await _context.Payments
                .Where(p => p.LeaseID == leaseId)
                .ToListAsync();
        }
    }
}

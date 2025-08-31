using System;
using System.ComponentModel.DataAnnotations;

namespace realEstate1.Models
{
	public class PaymentViewModel
	{
		[Required]
		public int LeaseID { get; set; }

		[Required]
		[Range(0.01 , double.MaxValue , ErrorMessage = "Amount must be greater than 0.")]
		public decimal Amount { get; set; }

		[Required]
		public DateTime Date { get; set; } = DateTime.UtcNow;
	}
}

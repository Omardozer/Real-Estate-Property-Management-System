using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace realEstate1.Models
{
	public class Payment
	{
		[Key]
		public int PaymentID { get; set; } 

		// Foreign Key to Lease
		public int LeaseID { get; set; }
		[ForeignKey("LeaseID")]
		public Lease Lease { get; set; }
		
		[Required]
		public decimal Amount { get; set; }

		[Required]
		public DateTime Date { get; set; }

		[Required]
		[StringLength(20)]
		public string Status { get; set; }   // "Completed", "Failed", "Pending"

		[Required]
		[StringLength(100)]
		public string TransactionId { get; set; }
		public string PaymentMethod { get; set; }
	}
}

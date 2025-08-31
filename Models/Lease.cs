using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace realEstate1.Models
{
	public class Lease
	{
		[Key]
		public int LeaseID { get; set; } // Primary Key

		// Linked Property
		[Required]
		public int PropertyID { get; set; }
		[ForeignKey("PropertyID")]
		public Property Property { get; set; }

		public DateTime CreatedDate { get; set; } = DateTime.Now; 

		[Required(ErrorMessage = "Start date is required.")]
		[DataType(DataType.Date)]
		public DateTime StartDate { get; set; }

		[Required(ErrorMessage = "End date is required.")]
		[DataType(DataType.Date)]
		public DateTime EndDate { get; set; }

		[Required(ErrorMessage = "Terms are required.")]
		[MaxLength(1000 , ErrorMessage = "Terms cannot exceed 1000 characters.")]
		public string Terms { get; set; }

		[Required]
		public Guid OwnerID { get; set; }
		[ForeignKey("OwnerID")]
		public ApplicationUser Owner { get; set; }


		[Required]
		public Guid TenantID { get; set; }
		[ForeignKey("TenantID")]
		public ApplicationUser Tenant { get; set; }
	}
}

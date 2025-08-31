using Microsoft.AspNetCore.Identity;
using System.ComponentModel.DataAnnotations;

namespace realEstate1.Models
{
	public class ApplicationUser : IdentityUser<Guid>
	{
		[Required(ErrorMessage = "Name is required.")]
		[MaxLength(100 , ErrorMessage = "Name cannot exceed 100 characters.")]
		public string Name { get; set; }

		[Required(ErrorMessage = "Phone number is required.")]
		[RegularExpression(@"^\d{10}$" , ErrorMessage = "Phone number must be exactly 10 digits.")]
		public override string PhoneNumber { get; set; }

		public ICollection<Lease> LeasesAsOwner { get; set; } = new List<Lease>();
		public ICollection<Lease> LeasesAsTenant { get; set; } = new List<Lease>();
		public ICollection<Property> properties { get; set; } = new List<Property>();

		public ICollection<Payment> Payments { get; set; } = new List<Payment>();
		public ICollection<IssueReport> IssueReports { get; set; } = new List<IssueReport>();
	}
}

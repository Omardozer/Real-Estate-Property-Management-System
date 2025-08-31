using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace realEstate1.Models
{
	public class Property
	{
		[Key]
		public int PropertyID { get; set; } 

		[Required(ErrorMessage = "Address is required.")]
		[MaxLength(255 , ErrorMessage = "Address cannot exceed 255 characters.")]
		public string Address { get; set; }

		[Required]
		public Guid OwnerID { get; set; }
		[ForeignKey("OwnerID")]
		public ApplicationUser? Owner { get; set; }

		[Required(ErrorMessage = "Property type is required.")]
		[MaxLength(50 , ErrorMessage = "Type cannot exceed 50 characters.")]
		[Display(Name = "Property Type")]
		public string Type { get; set; }

		[Range(0 , 50 , ErrorMessage = "Bedrooms must be between 0 and 50.")]
		public int Bedrooms { get; set; }

		[Range(0 , 50 , ErrorMessage = "Bathrooms must be between 0 and 50.")]
		public int Bathrooms { get; set; }

		[Required(ErrorMessage = "Price per day is required.")]
		[Range(1 , double.MaxValue , ErrorMessage = "Price per day must be greater than 0.")]
		[DataType(DataType.Currency)]
		[Column(TypeName = "decimal(18,2)")] 
		[Display(Name = "Price Per Day")]
		public decimal PricePerDay { get; set; }

		[MaxLength(1000 , ErrorMessage = "Description cannot exceed 1000 characters.")]
		public string Description { get; set; }
		public string terms { get; set; }

		[DataType(DataType.DateTime)]
		public DateTime CreatedDate { get; set; } = DateTime.Now;

		public ICollection<Lease> Leases { get; set; } = new List<Lease>();
		public ICollection<PropertyImage> PropertiesImages { get; set; } = new List<PropertyImage>();
	}
}

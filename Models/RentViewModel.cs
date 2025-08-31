using System.ComponentModel.DataAnnotations;

namespace realEstate1.Models
{
    public class RentViewModel
    {
        public int PropertyId { get; set; }

        [Required(ErrorMessage = "Start date is required.")]
        [DataType(DataType.Date)]
        public DateTime StartDate { get; set; }

        [Required(ErrorMessage = "End date is required.")]
        [DataType(DataType.Date)]
        [CustomValidation(typeof(RentViewModel), nameof(ValidateDates))]
        public DateTime EndDate { get; set; }

        public string Address { get; set; }
        public string terms { get; set; }
        public Guid OwnerId { get; set; }
        public string Description { get; set; }
        public decimal PricePerDay { get; set; }

        public static ValidationResult? ValidateDates(DateTime endDate, ValidationContext context)
        {
            var instance = context.ObjectInstance as RentViewModel;
            if (instance != null && instance.StartDate >= endDate)
            {
                return new ValidationResult("End date must be after the start date.");
            }

            return ValidationResult.Success;
        }
    }

}
using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;

namespace realEstate1.Models
{
    public class IssueReport
    {
        [Key]
        public int IssueID { get; set; } 

        public Guid TenantID { get; set; }

        [ForeignKey("TenantID")]
        public ApplicationUser Tenant { get; set; }

        [Required(ErrorMessage = "Description is required.")]
        [MaxLength(1000, ErrorMessage = "Description cannot exceed 1000 characters.")]
        public string Description { get; set; }

        [Required(ErrorMessage = "Date reported is required.")]
        public DateTime DateReported { get; set; }

        [MaxLength(50, ErrorMessage = "Status cannot exceed 50 characters.")]
        public string Status { get; set; }
    }
}

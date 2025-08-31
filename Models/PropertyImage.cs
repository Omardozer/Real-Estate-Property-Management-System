using System.ComponentModel.DataAnnotations;

namespace realEstate1.Models
{
    public class PropertyImage
    {
        [Key]
        public int ImageID { get; set; }

        public string ImagePath { get; set; } 

        public int PropertyID { get; set; }

        
        public Property Property { get; set; }
    }
}

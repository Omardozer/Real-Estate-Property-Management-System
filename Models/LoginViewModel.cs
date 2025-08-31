using System.ComponentModel.DataAnnotations;

namespace realEstate1.Models
{
    public class LoginViewModel
	{
		[Required]
		public string Email { get; set; }
		public string UserName { get; set; }

		[Required]
		public string Password { get; set; }
		[Required]
		public bool RememberMe { get; set; }

    }

}

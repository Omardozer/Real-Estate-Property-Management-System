using realEstate1.Data;
using realEstate1.Interfaces;
using realEstate1.Models;

namespace realEstate1.Services
{
    public class ImageService : IImages
    {
        private readonly MyAppDbContext _context;
        

        public ImageService(MyAppDbContext context)
        {
            _context = context;
            
        }

        public void SaveImages(int propertyId, List<IFormFile> imageFiles)
        {
            foreach (var imageFile in imageFiles)
            {
                var fileName = Path.GetFileName(imageFile.FileName);
                var filePath = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot/images", fileName);

                using (var stream = new FileStream(filePath, FileMode.Create))
                {
                    imageFile.CopyTo(stream);
                }

      

                    var propertyImage = new PropertyImage
                    {
                        ImagePath = fileName,
                        PropertyID = propertyId
                    };
                    _context.PropertiesImages.Add(propertyImage);
                    _context.SaveChanges();
                
            }
        }
    }
}

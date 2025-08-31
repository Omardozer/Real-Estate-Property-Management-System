namespace realEstate1.Interfaces
{
    public interface IImages
    {
        void SaveImages(int propertyId, List<IFormFile> imageFiles);
    }
}

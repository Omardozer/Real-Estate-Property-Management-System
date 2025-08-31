namespace realEstate1.Models
{
    public class LeaseViewModel
    {
        public int PropertyID { get; set; }
        public int LeaseID { get; set; }
        public Guid TenantID { get; set; }
        public Guid OwnerID { get; set; }
        public string PropertyAddress { get; set; }
        public string TenantName { get; set; }
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        public string Terms { get; set; }
    }

}

using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using realEstate1.Models;
using System.Reflection.Emit;

namespace realEstate1.Data
{
    public class MyAppDbContext : IdentityDbContext<ApplicationUser , IdentityRole<Guid> , Guid>

	{
        public MyAppDbContext()
        {
        }

        public MyAppDbContext(DbContextOptions<MyAppDbContext>options):base(options) 
        {
            
        }
		protected override void OnModelCreating(ModelBuilder builder)
		{
			base.OnModelCreating(builder);
			builder.Entity<Lease>(b =>
			{
				b.HasKey(l => l.LeaseID);

				// Property relationship
				b.HasOne(l => l.Property)
					.WithMany(p => p.Leases)              // Add ICollection<Lease> Leases in Property
					.HasForeignKey(l => l.PropertyID)
					.OnDelete(DeleteBehavior.Restrict);   // Avoid cascade cycles

				// Owner relationship (AspNetUsers)
				b.HasOne(l => l.Owner)
					.WithMany(u => u.LeasesAsOwner)       // Add ICollection<Lease> LeasesAsOwner in ApplicationUser
					.HasForeignKey(l => l.OwnerID)
					.OnDelete(DeleteBehavior.Restrict);

				// Tenant relationship (AspNetUsers)
				b.HasOne(l => l.Tenant)
					.WithMany(u => u.LeasesAsTenant)      // Add ICollection<Lease> LeasesAsTenant in ApplicationUser
					.HasForeignKey(l => l.TenantID)
					.OnDelete(DeleteBehavior.Restrict);

				// DB-side default for CreatedDate
				b.Property(l => l.CreatedDate)
					.HasDefaultValueSql("GETUTCDATE()");


				b.ToTable(tb => tb.HasCheckConstraint(
					"CK_Lease_EndDate_After_StartDate" ,
					"[EndDate] > [StartDate]"));
			});
		}
		public DbSet<Property> Properties { get; set; }

        public DbSet<Lease> Leases { get; set; }
        public DbSet<IssueReport> Issues { get; set; }
        public DbSet<Payment> Payments { get; set; }
        public DbSet<PropertyImage> PropertiesImages { get;  set; }
    }
}

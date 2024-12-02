-- Tạo Cơ Sở Dữ Liệu Điện Tử
CREATE DATABASE ElectronicShop;
GO

USE ElectronicShop;
GO

-- Bảng Roles
CREATE TABLE Roles (
    RoleID INT IDENTITY(1,1) PRIMARY KEY,
    RoleName NVARCHAR(100) NOT NULL UNIQUE,
    Description NVARCHAR(255) NULL
);

-- Bảng Users
CREATE TABLE Users (
    UserID INT IDENTITY(1,1) PRIMARY KEY,
    Username NVARCHAR(50) NOT NULL UNIQUE,
    Email NVARCHAR(255) NOT NULL UNIQUE,
    PhoneNumber NVARCHAR(15) NULL,
    PasswordHash NVARCHAR(255) NOT NULL,
    Salt NVARCHAR(50) NOT NULL,
    FullName NVARCHAR(100) NOT NULL,
    DateOfBirth DATE NULL,
    Gender NVARCHAR(10) NULL,
    ProfileImageURL NVARCHAR(255) NULL,
    RegistrationDate DATETIME DEFAULT GETDATE(),
    LastLoginDate DATETIME NULL,
    Status NVARCHAR(20) DEFAULT 'Active', -- Active, Inactive, Blocked
    EmailVerified BIT DEFAULT 0,
    TwoFactorEnabled BIT DEFAULT 0,
    IsDeleted BIT DEFAULT 0, -- Xóa mềm
    DeletedAt DATETIME NULL
);

-- Bảng Employees
CREATE TABLE Employees (
    EmployeeID INT IDENTITY(1,1) PRIMARY KEY,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Email NVARCHAR(255) NOT NULL UNIQUE,
    PhoneNumber NVARCHAR(15) NULL,
    PasswordHash NVARCHAR(255) NOT NULL,
    Salt NVARCHAR(50) NOT NULL,
    RoleID INT NOT NULL,
    HireDate DATE NOT NULL DEFAULT GETDATE(),
    TerminationDate DATE NULL,
    ProfileImageURL NVARCHAR(255) NULL,
    Status NVARCHAR(20) DEFAULT 'Active', -- Active, Inactive, Suspended
    IsDeleted BIT DEFAULT 0, -- Xóa mềm
    DeletedAt DATETIME NULL,
    FOREIGN KEY (RoleID) REFERENCES Roles(RoleID)
);

-- Bảng Logs (Ghi lại các thay đổi quan trọng)
CREATE TABLE Logs (
    LogID INT IDENTITY(1,1) PRIMARY KEY,
    TableName NVARCHAR(50) NOT NULL,
    RecordID INT NOT NULL,
    Action NVARCHAR(50) NOT NULL, -- INSERT, UPDATE, DELETE
    OldData NVARCHAR(MAX) NULL,
    NewData NVARCHAR(MAX) NULL,
    ChangedBy INT NULL, -- UserID của người thực hiện
    ChangedAt DATETIME DEFAULT GETDATE()
);

-- Bảng UserAddresses
CREATE TABLE UserAddresses (
    AddressID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL,
    AddressType NVARCHAR(50) NOT NULL, -- Home, Work, Shipping
    FullName NVARCHAR(100) NOT NULL,
    PhoneNumber NVARCHAR(15) NOT NULL,
    Address NVARCHAR(255) NOT NULL,
    City NVARCHAR(100) NOT NULL,
    Province NVARCHAR(100) NOT NULL,
    PostalCode NVARCHAR(20) NOT NULL,
    IsDefault BIT DEFAULT 0,
    IsDeleted BIT DEFAULT 0, -- Xóa mềm
    DeletedAt DATETIME NULL,
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);

-- Bảng ProductCategories
CREATE TABLE ProductCategories (
    CategoryID INT IDENTITY(1,1) PRIMARY KEY,
    CategoryName NVARCHAR(100) NOT NULL,
    ParentCategoryID INT NULL,
    Description NVARCHAR(500) NULL,
    ImageURL NVARCHAR(255) NULL,
    DisplayOrder INT DEFAULT 0,
    Status NVARCHAR(20) DEFAULT 'Active', -- Active, Inactive
    IsDeleted BIT DEFAULT 0, -- Xóa mềm
    DeletedAt DATETIME NULL,
    FOREIGN KEY (ParentCategoryID) REFERENCES ProductCategories(CategoryID)
);

-- Bảng Brands
CREATE TABLE Brands (
    BrandID INT IDENTITY(1,1) PRIMARY KEY,
    BrandName NVARCHAR(100) NOT NULL,
    LogoURL NVARCHAR(255) NULL,
    Description NVARCHAR(500) NULL,
    WebsiteURL NVARCHAR(255) NULL,
    Status NVARCHAR(20) DEFAULT 'Active',
    IsDeleted BIT DEFAULT 0, -- Xóa mềm
    DeletedAt DATETIME NULL
);

-- Bảng Products
CREATE TABLE Products (
    ProductID INT IDENTITY(1,1) PRIMARY KEY,
    ProductName NVARCHAR(255) NOT NULL,
    CategoryID INT NOT NULL,
    BrandID INT NOT NULL,
    Description NVARCHAR(MAX) NULL,
    ShortDescription NVARCHAR(500) NULL,
    Price DECIMAL(10,2) NOT NULL,
    DiscountPrice DECIMAL(10,2) NULL,
    StockQuantity INT NOT NULL DEFAULT 0,
    MainImageURL NVARCHAR(255) NULL,
    Status NVARCHAR(20) DEFAULT 'Active', -- Active, Inactive, OutOfStock
    IsFeatured BIT DEFAULT 0,
    CreatedDate DATETIME DEFAULT GETDATE(),
    IsDeleted BIT DEFAULT 0, -- Xóa mềm
    DeletedAt DATETIME NULL,
    FOREIGN KEY (CategoryID) REFERENCES ProductCategories(CategoryID),
    FOREIGN KEY (BrandID) REFERENCES Brands(BrandID)
);

-- Bảng OrderDetails
CREATE TABLE OrderDetails (
    OrderDetailID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);

-- Bảng Orders
CREATE TABLE Orders (
    OrderID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL,
    OrderNumber NVARCHAR(50) NOT NULL UNIQUE,
    TotalAmount DECIMAL(10,2) NOT NULL,
    DiscountAmount DECIMAL(10,2) DEFAULT 0,
    ShippingAmount DECIMAL(10,2) DEFAULT 0,
    OrderDate DATETIME DEFAULT GETDATE(),
    Status NVARCHAR(50) DEFAULT 'Pending', -- Pending, Processing, Shipped, Delivered, Cancelled
    ShippingAddressID INT NOT NULL,
    PaymentMethod NVARCHAR(50) NOT NULL,
    Notes NVARCHAR(500) NULL,
    IsDeleted BIT DEFAULT 0, -- Xóa mềm
    DeletedAt DATETIME NULL,
    FOREIGN KEY (UserID) REFERENCES Users(UserID),
    FOREIGN KEY (ShippingAddressID) REFERENCES UserAddresses(AddressID)
);

-- Bảng ProductImages
CREATE TABLE ProductImages (
    ImageID INT IDENTITY(1,1) PRIMARY KEY,
    ProductID INT NOT NULL,
    ImageURL NVARCHAR(255) NOT NULL,
    DisplayOrder INT DEFAULT 0,
    IsDeleted BIT DEFAULT 0, -- Xóa mềm
    DeletedAt DATETIME NULL,
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);

-- Bảng ProductSpecifications
CREATE TABLE ProductSpecifications (
    SpecID INT IDENTITY(1,1) PRIMARY KEY,
    ProductID INT NOT NULL,
    SpecName NVARCHAR(100) NOT NULL,
    SpecValue NVARCHAR(255) NOT NULL,
    IsDeleted BIT DEFAULT 0, -- Xóa mềm
    DeletedAt DATETIME NULL,
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);

-- Bảng Cart
CREATE TABLE Cart (
    CartID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT NOT NULL DEFAULT 1,
    AddedDate DATETIME DEFAULT GETDATE(),
    IsDeleted BIT DEFAULT 0, -- Xóa mềm
    DeletedAt DATETIME NULL,
    FOREIGN KEY (UserID) REFERENCES Users(UserID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);

-- Bảng ProductReviews
CREATE TABLE ProductReviews (
    ReviewID INT IDENTITY(1,1) PRIMARY KEY,
    ProductID INT NOT NULL,
    UserID INT NOT NULL,
    Rating INT NOT NULL CHECK (Rating BETWEEN 1 AND 5),
    ReviewText NVARCHAR(MAX) NULL,
    ReviewDate DATETIME DEFAULT GETDATE(),
    Status NVARCHAR(20) DEFAULT 'Pending', -- Pending, Approved, Rejected
    IsDeleted BIT DEFAULT 0, -- Xóa mềm
    DeletedAt DATETIME NULL,
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID),
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);

-- Bảng Promotions
CREATE TABLE Promotions (
    PromotionID INT IDENTITY(1,1) PRIMARY KEY,
    PromotionName NVARCHAR(255) NOT NULL,
    Description NVARCHAR(500) NULL,
    DiscountType NVARCHAR(50) NOT NULL, -- Percentage, FixedAmount
    DiscountValue DECIMAL(10,2) NOT NULL,
    StartDate DATETIME NOT NULL,
    EndDate DATETIME NOT NULL,
    Status NVARCHAR(20) DEFAULT 'Active', -- Active, Inactive
    IsDeleted BIT DEFAULT 0, -- Xóa mềm
    DeletedAt DATETIME NULL
);

-- Bảng OrderTracking
CREATE TABLE OrderTracking (
    TrackingID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT NOT NULL,
    Status NVARCHAR(50) NOT NULL,
    Location NVARCHAR(255) NULL,
    UpdatedDate DATETIME DEFAULT GETDATE(),
    IsDeleted BIT DEFAULT 0, -- Xóa mềm
    DeletedAt DATETIME NULL,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
);

-- Bảng Wishlist
CREATE TABLE Wishlist (
    WishlistID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL,
    ProductID INT NOT NULL,
    AddedDate DATETIME DEFAULT GETDATE(),
    IsDeleted BIT DEFAULT 0, -- Xóa mềm
    DeletedAt DATETIME NULL,
    FOREIGN KEY (UserID) REFERENCES Users(UserID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);

-- Bảng TwoFactorTokens
CREATE TABLE TwoFactorTokens (
    TokenID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL,
    TokenHash NVARCHAR(255) NOT NULL,
    TokenType NVARCHAR(50) NOT NULL, -- Email, SMS
    ExpiresAt DATETIME NOT NULL,
    CreatedAt DATETIME DEFAULT GETDATE(),
    IsDeleted BIT DEFAULT 0, -- Xóa mềm
    DeletedAt DATETIME NULL,
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);

import '../../features/auth/domain/entities/user.dart';
import '../../features/menu/domain/entities/outlet.dart';
import '../../features/menu/domain/entities/category.dart';
import '../../features/menu/domain/entities/menu_item.dart';
import '../../features/menu/domain/entities/modifier_group.dart';
import '../../features/menu/domain/entities/modifier.dart';
import '../../features/notifications/domain/entities/notification.dart';
import '../../features/orders/domain/entities/master_order.dart';
import '../../features/orders/domain/entities/sub_order.dart';
import '../../features/orders/domain/entities/order_line_item.dart';

abstract final class MockData {
  // ──────────────────────────────────────────────────────────────────────────
  // Current authenticated user
  // ──────────────────────────────────────────────────────────────────────────

  static const User currentUser = User(
    id: 'a0a1b2c3-d4e5-6789-abcd-ef0123456789',
    name: 'Adaeze O',
    phone: '08031234567',
    email: 'adaeze.o@gmail.com',
  );

  // ──────────────────────────────────────────────────────────────────────────
  // Outlets
  // ──────────────────────────────────────────────────────────────────────────

  static const List<Outlet> outlets = [
    Outlet(
      id: 'f47ac10b-58cc-4372-a567-0e02b2c3d479',
      name: 'Cactus Grill',
      description:
          'Authentic Nigerian grills, BBQ, and suya. Flame-kissed flavours straight from the grill.',
      cuisineType: 'Grills · BBQ · Nigerian',
      imageUrl: 'https://via.placeholder.com/400x300',
      isOnline: true,
      rating: 4.8,
      deliveryTimeMins: 25,
      minOrder: 2000.00,
    ),
    Outlet(
      id: '550e8400-e29b-41d4-a716-446655440000',
      name: 'Salmas',
      description:
          'Premium sushi, ramen, and Thai favourites crafted with fresh ingredients.',
      cuisineType: 'Sushi · Noodles · Thai',
      imageUrl: 'https://via.placeholder.com/400x300',
      isOnline: true,
      rating: 4.6,
      deliveryTimeMins: 30,
      minOrder: 3000.00,
    ),
    Outlet(
      id: '6ba7b810-9dad-11d1-80b4-00c04fd430c8',
      name: "Mama's Kitchen",
      description:
          'Home-style Nigerian cooking — soups, swallows, and rice dishes made with love.',
      cuisineType: 'Nigerian · Traditional',
      imageUrl: 'https://via.placeholder.com/400x300',
      isOnline: true,
      rating: 4.9,
      deliveryTimeMins: 20,
      minOrder: 1500.00,
    ),
    Outlet(
      id: '7c9e6679-7425-40de-944b-e07fc1f90ae7',
      name: 'Crispy Corner',
      description:
          'Juicy smash burgers, crispy fried chicken, and thick milkshakes.',
      cuisineType: 'Burgers · Fried Chicken · Fast Food',
      imageUrl: 'https://via.placeholder.com/400x300',
      isOnline: false,
      rating: 4.3,
      deliveryTimeMins: 15,
      minOrder: 1000.00,
    ),
  ];

  // ──────────────────────────────────────────────────────────────────────────
  // Menu categories
  // ──────────────────────────────────────────────────────────────────────────

  static const List<MenuCategory> categories = [
    // Cactus Grill
    MenuCategory(id: 'cat-cactus-01', outletId: 'f47ac10b-58cc-4372-a567-0e02b2c3d479', name: 'Grills & BBQ', sortOrder: 1),
    MenuCategory(id: 'cat-cactus-02', outletId: 'f47ac10b-58cc-4372-a567-0e02b2c3d479', name: 'Nigerian Classics', sortOrder: 2),
    MenuCategory(id: 'cat-cactus-03', outletId: 'f47ac10b-58cc-4372-a567-0e02b2c3d479', name: 'Sides & Extras', sortOrder: 3),
    MenuCategory(id: 'cat-cactus-04', outletId: 'f47ac10b-58cc-4372-a567-0e02b2c3d479', name: 'Drinks', sortOrder: 4),

    // Salmas
    MenuCategory(id: 'cat-salmas-01', outletId: '550e8400-e29b-41d4-a716-446655440000', name: 'Sushi Rolls', sortOrder: 1),
    MenuCategory(id: 'cat-salmas-02', outletId: '550e8400-e29b-41d4-a716-446655440000', name: 'Noodles & Ramen', sortOrder: 2),
    MenuCategory(id: 'cat-salmas-03', outletId: '550e8400-e29b-41d4-a716-446655440000', name: 'Thai Mains', sortOrder: 3),
    MenuCategory(id: 'cat-salmas-04', outletId: '550e8400-e29b-41d4-a716-446655440000', name: 'Starters', sortOrder: 4),

    // Mama's Kitchen
    MenuCategory(id: 'cat-mamas-01', outletId: '6ba7b810-9dad-11d1-80b4-00c04fd430c8', name: 'Soups & Swallows', sortOrder: 1),
    MenuCategory(id: 'cat-mamas-02', outletId: '6ba7b810-9dad-11d1-80b4-00c04fd430c8', name: 'Rice Dishes', sortOrder: 2),
    MenuCategory(id: 'cat-mamas-03', outletId: '6ba7b810-9dad-11d1-80b4-00c04fd430c8', name: 'Small Chops & Snacks', sortOrder: 3),
    MenuCategory(id: 'cat-mamas-04', outletId: '6ba7b810-9dad-11d1-80b4-00c04fd430c8', name: 'Protein Add-ons', sortOrder: 4),

    // Crispy Corner
    MenuCategory(id: 'cat-crispy-01', outletId: '7c9e6679-7425-40de-944b-e07fc1f90ae7', name: 'Burgers', sortOrder: 1),
    MenuCategory(id: 'cat-crispy-02', outletId: '7c9e6679-7425-40de-944b-e07fc1f90ae7', name: 'Fried Chicken', sortOrder: 2),
    MenuCategory(id: 'cat-crispy-03', outletId: '7c9e6679-7425-40de-944b-e07fc1f90ae7', name: 'Sides', sortOrder: 3),
    MenuCategory(id: 'cat-crispy-04', outletId: '7c9e6679-7425-40de-944b-e07fc1f90ae7', name: 'Shakes & Drinks', sortOrder: 4),
  ];

  // ──────────────────────────────────────────────────────────────────────────
  // Menu items
  // ──────────────────────────────────────────────────────────────────────────

  static const List<MenuItem> menuItems = [
    // ── Cactus Grill — Grills & BBQ ─────────────────────────────────────────
    MenuItem(
      id: '1a2b3c4d-0001-0000-0000-000000000001',
      categoryId: 'cat-cactus-01',
      outletId: 'f47ac10b-58cc-4372-a567-0e02b2c3d479',
      name: 'Suya (per portion)',
      description: 'Thinly sliced spiced meat skewers served with sliced onion and tomato.',
      price: 2500.00,
      imageUrl: 'https://via.placeholder.com/400x300',
      isAvailable: true,
      allergenNote: 'Peanut-free option available upon kitchen request.',
      modifierGroups: [
        ModifierGroup(
          id: 'mg-suya-protein',
          menuItemId: '1a2b3c4d-0001-0000-0000-000000000001',
          name: 'Choose Protein',
          isRequired: true,
          maxSelections: 1,
          modifiers: [
            Modifier(id: 'mod-suya-chicken', groupId: 'mg-suya-protein', name: 'Chicken', priceDelta: 0.00),
            Modifier(id: 'mod-suya-beef',    groupId: 'mg-suya-protein', name: 'Beef',    priceDelta: 500.00),
            Modifier(id: 'mod-suya-gizzard', groupId: 'mg-suya-protein', name: 'Gizzard', priceDelta: 300.00),
            Modifier(id: 'mod-suya-kidney',  groupId: 'mg-suya-protein', name: 'Kidney',  priceDelta: 200.00),
          ],
        ),
      ],
    ),
    MenuItem(
      id: '1a2b3c4d-0001-0000-0000-000000000002',
      categoryId: 'cat-cactus-01',
      outletId: 'f47ac10b-58cc-4372-a567-0e02b2c3d479',
      name: 'Grilled Chicken (half)',
      description: 'Tender half chicken marinated in RSC house spice blend, slow-grilled to perfection.',
      price: 4500.00,
      imageUrl: 'https://via.placeholder.com/400x300',
      isAvailable: true,
      modifierGroups: [
        ModifierGroup(
          id: 'mg-gchicken-spice',
          menuItemId: '1a2b3c4d-0001-0000-0000-000000000002',
          name: 'Spice Level',
          isRequired: false,
          maxSelections: 1,
          modifiers: [
            Modifier(id: 'mod-spice-mild',   groupId: 'mg-gchicken-spice', name: 'Mild',       priceDelta: 0.00),
            Modifier(id: 'mod-spice-medium', groupId: 'mg-gchicken-spice', name: 'Medium',     priceDelta: 0.00),
            Modifier(id: 'mod-spice-hot',    groupId: 'mg-gchicken-spice', name: 'Hot',        priceDelta: 0.00),
            Modifier(id: 'mod-spice-xhot',   groupId: 'mg-gchicken-spice', name: 'Extra Hot',  priceDelta: 0.00),
          ],
        ),
        ModifierGroup(
          id: 'mg-gchicken-side',
          menuItemId: '1a2b3c4d-0001-0000-0000-000000000002',
          name: 'Add a Side',
          isRequired: false,
          maxSelections: 2,
          modifiers: [
            Modifier(id: 'mod-side-coleslaw',  groupId: 'mg-gchicken-side', name: 'Coleslaw',  priceDelta: 500.00),
            Modifier(id: 'mod-side-fries',     groupId: 'mg-gchicken-side', name: 'Fries',     priceDelta: 700.00),
            Modifier(id: 'mod-side-plantain',  groupId: 'mg-gchicken-side', name: 'Plantain',  priceDelta: 500.00),
          ],
        ),
      ],
    ),
    MenuItem(
      id: '1a2b3c4d-0001-0000-0000-000000000003',
      categoryId: 'cat-cactus-01',
      outletId: 'f47ac10b-58cc-4372-a567-0e02b2c3d479',
      name: 'Grilled Tilapia',
      description: 'Whole tilapia seasoned with herbs and charcoal-grilled. Served with pepper sauce.',
      price: 5500.00,
      imageUrl: 'https://via.placeholder.com/400x300',
      isAvailable: true,
    ),
    MenuItem(
      id: '1a2b3c4d-0001-0000-0000-000000000004',
      categoryId: 'cat-cactus-01',
      outletId: 'f47ac10b-58cc-4372-a567-0e02b2c3d479',
      name: 'BBQ Spare Ribs',
      description: 'Slow-cooked pork ribs glazed with RSC signature BBQ sauce.',
      price: 7500.00,
      imageUrl: 'https://via.placeholder.com/400x300',
      isAvailable: true,
    ),
    // ── Cactus Grill — Nigerian Classics ────────────────────────────────────
    MenuItem(
      id: '1a2b3c4d-0002-0000-0000-000000000001',
      categoryId: 'cat-cactus-02',
      outletId: 'f47ac10b-58cc-4372-a567-0e02b2c3d479',
      name: 'Jollof Rice',
      description: 'Party-style smoky jollof rice cooked in rich tomato-pepper base.',
      price: 2500.00,
      imageUrl: 'https://via.placeholder.com/400x300',
      isAvailable: true,
    ),
    MenuItem(
      id: '1a2b3c4d-0002-0000-0000-000000000002',
      categoryId: 'cat-cactus-02',
      outletId: 'f47ac10b-58cc-4372-a567-0e02b2c3d479',
      name: 'Fried Rice',
      description: 'Nigerian-style fried rice loaded with vegetables, liver, and shrimp.',
      price: 2500.00,
      imageUrl: 'https://via.placeholder.com/400x300',
      isAvailable: true,
    ),
    MenuItem(
      id: '1a2b3c4d-0002-0000-0000-000000000003',
      categoryId: 'cat-cactus-02',
      outletId: 'f47ac10b-58cc-4372-a567-0e02b2c3d479',
      name: 'Pounded Yam + Egusi',
      description: 'Smooth pounded yam served with rich egusi soup and assorted meat.',
      price: 4500.00,
      imageUrl: 'https://via.placeholder.com/400x300',
      isAvailable: false, // currently unavailable
    ),
    // ── Cactus Grill — Sides & Extras ───────────────────────────────────────
    MenuItem(
      id: '1a2b3c4d-0003-0000-0000-000000000001',
      categoryId: 'cat-cactus-03',
      outletId: 'f47ac10b-58cc-4372-a567-0e02b2c3d479',
      name: 'Coleslaw',
      description: 'Creamy homemade coleslaw.',
      price: 800.00,
      imageUrl: 'https://via.placeholder.com/400x300',
      isAvailable: true,
    ),
    MenuItem(
      id: '1a2b3c4d-0003-0000-0000-000000000002',
      categoryId: 'cat-cactus-03',
      outletId: 'f47ac10b-58cc-4372-a567-0e02b2c3d479',
      name: 'Fried Plantain',
      description: 'Sweet ripe plantain, deep-fried golden.',
      price: 1000.00,
      imageUrl: 'https://via.placeholder.com/400x300',
      isAvailable: true,
    ),
    MenuItem(
      id: '1a2b3c4d-0003-0000-0000-000000000003',
      categoryId: 'cat-cactus-03',
      outletId: 'f47ac10b-58cc-4372-a567-0e02b2c3d479',
      name: 'Puff Puff (6 pieces)',
      description: 'Soft, fluffy Nigerian deep-fried dough balls.',
      price: 600.00,
      imageUrl: 'https://via.placeholder.com/400x300',
      isAvailable: true,
    ),
    // ── Cactus Grill — Drinks ────────────────────────────────────────────────
    MenuItem(
      id: '1a2b3c4d-0004-0000-0000-000000000001',
      categoryId: 'cat-cactus-04',
      outletId: 'f47ac10b-58cc-4372-a567-0e02b2c3d479',
      name: 'Chapman',
      description: 'Classic Nigerian Chapman cocktail — fruity and refreshing.',
      price: 1200.00,
      imageUrl: 'https://via.placeholder.com/400x300',
      isAvailable: true,
    ),
    MenuItem(
      id: '1a2b3c4d-0004-0000-0000-000000000002',
      categoryId: 'cat-cactus-04',
      outletId: 'f47ac10b-58cc-4372-a567-0e02b2c3d479',
      name: 'Zobo (bottle)',
      description: 'Chilled hibiscus drink with ginger and pineapple.',
      price: 800.00,
      imageUrl: 'https://via.placeholder.com/400x300',
      isAvailable: true,
    ),

    // ── Salmas — Sushi Rolls ─────────────────────────────────────────────────
    MenuItem(
      id: '2b3c4d5e-0001-0000-0000-000000000001',
      categoryId: 'cat-salmas-01',
      outletId: '550e8400-e29b-41d4-a716-446655440000',
      name: 'California Roll (8 pcs)',
      description: 'Crab, avocado, and cucumber wrapped in seasoned sushi rice and nori.',
      price: 6500.00,
      imageUrl: 'https://via.placeholder.com/400x300',
      isAvailable: true,
      modifierGroups: [
        ModifierGroup(
          id: 'mg-cali-addons',
          menuItemId: '2b3c4d5e-0001-0000-0000-000000000001',
          name: 'Add-ons',
          isRequired: false,
          maxSelections: 2,
          modifiers: [
            Modifier(id: 'mod-cali-avo',    groupId: 'mg-cali-addons', name: 'Extra Avocado', priceDelta: 800.00),
            Modifier(id: 'mod-cali-tobiko', groupId: 'mg-cali-addons', name: 'Tobiko',        priceDelta: 1000.00),
            Modifier(id: 'mod-cali-cc',     groupId: 'mg-cali-addons', name: 'Cream Cheese',  priceDelta: 500.00),
          ],
        ),
      ],
    ),
    MenuItem(
      id: '2b3c4d5e-0001-0000-0000-000000000002',
      categoryId: 'cat-salmas-01',
      outletId: '550e8400-e29b-41d4-a716-446655440000',
      name: 'Spicy Tuna Roll (8 pcs)',
      description: 'Fresh tuna with spicy mayo, cucumber, and sesame seeds.',
      price: 7500.00,
      imageUrl: 'https://via.placeholder.com/400x300',
      isAvailable: true,
    ),
    MenuItem(
      id: '2b3c4d5e-0001-0000-0000-000000000003',
      categoryId: 'cat-salmas-01',
      outletId: '550e8400-e29b-41d4-a716-446655440000',
      name: 'Dragon Roll (8 pcs)',
      description: 'Shrimp tempura topped with avocado and unagi sauce.',
      price: 9000.00,
      imageUrl: 'https://via.placeholder.com/400x300',
      isAvailable: true,
    ),
    MenuItem(
      id: '2b3c4d5e-0001-0000-0000-000000000004',
      categoryId: 'cat-salmas-01',
      outletId: '550e8400-e29b-41d4-a716-446655440000',
      name: 'Vegetarian Roll (8 pcs)',
      description: 'Cucumber, avocado, pickled radish, and carrots.',
      price: 5500.00,
      imageUrl: 'https://via.placeholder.com/400x300',
      isAvailable: false, // out of season ingredients
    ),
    // ── Salmas — Noodles & Ramen ─────────────────────────────────────────────
    MenuItem(
      id: '2b3c4d5e-0002-0000-0000-000000000001',
      categoryId: 'cat-salmas-02',
      outletId: '550e8400-e29b-41d4-a716-446655440000',
      name: 'Tonkotsu Ramen',
      description: 'Rich pork bone broth with chashu, soft-boiled egg, nori, and bamboo shoots.',
      price: 7500.00,
      imageUrl: 'https://via.placeholder.com/400x300',
      isAvailable: true,
      modifierGroups: [
        ModifierGroup(
          id: 'mg-tonkotsu-protein',
          menuItemId: '2b3c4d5e-0002-0000-0000-000000000001',
          name: 'Protein',
          isRequired: true,
          maxSelections: 1,
          modifiers: [
            Modifier(id: 'mod-tk-pork',    groupId: 'mg-tonkotsu-protein', name: 'Chashu Pork', priceDelta: 0.00),
            Modifier(id: 'mod-tk-chicken', groupId: 'mg-tonkotsu-protein', name: 'Chicken',     priceDelta: 0.00),
            Modifier(id: 'mod-tk-tofu',    groupId: 'mg-tonkotsu-protein', name: 'Tofu',        priceDelta: 0.00),
          ],
        ),
      ],
    ),
    MenuItem(
      id: '2b3c4d5e-0002-0000-0000-000000000002',
      categoryId: 'cat-salmas-02',
      outletId: '550e8400-e29b-41d4-a716-446655440000',
      name: 'Pad Thai',
      description: 'Stir-fried rice noodles with bean sprouts, peanuts, and tamarind sauce.',
      price: 6500.00,
      imageUrl: 'https://via.placeholder.com/400x300',
      isAvailable: true,
    ),
    MenuItem(
      id: '2b3c4d5e-0002-0000-0000-000000000003',
      categoryId: 'cat-salmas-02',
      outletId: '550e8400-e29b-41d4-a716-446655440000',
      name: 'Beef Yakisoba',
      description: 'Japanese stir-fried noodles with tender beef, cabbage, and yakisoba sauce.',
      price: 7000.00,
      imageUrl: 'https://via.placeholder.com/400x300',
      isAvailable: true,
    ),
    // ── Salmas — Thai Mains ──────────────────────────────────────────────────
    MenuItem(
      id: '2b3c4d5e-0003-0000-0000-000000000001',
      categoryId: 'cat-salmas-03',
      outletId: '550e8400-e29b-41d4-a716-446655440000',
      name: 'Green Curry Chicken',
      description: 'Fragrant Thai green curry with coconut milk, bamboo shoots, and jasmine rice.',
      price: 6500.00,
      imageUrl: 'https://via.placeholder.com/400x300',
      isAvailable: true,
    ),
    MenuItem(
      id: '2b3c4d5e-0003-0000-0000-000000000002',
      categoryId: 'cat-salmas-03',
      outletId: '550e8400-e29b-41d4-a716-446655440000',
      name: 'Massaman Curry',
      description: 'Slow-cooked beef in rich Massaman sauce with potatoes and peanuts.',
      price: 7000.00,
      imageUrl: 'https://via.placeholder.com/400x300',
      isAvailable: true,
    ),
    // ── Salmas — Starters ────────────────────────────────────────────────────
    MenuItem(
      id: '2b3c4d5e-0004-0000-0000-000000000001',
      categoryId: 'cat-salmas-04',
      outletId: '550e8400-e29b-41d4-a716-446655440000',
      name: 'Gyoza (6 pcs)',
      description: 'Pan-fried Japanese dumplings filled with pork and cabbage.',
      price: 3500.00,
      imageUrl: 'https://via.placeholder.com/400x300',
      isAvailable: true,
    ),
    MenuItem(
      id: '2b3c4d5e-0004-0000-0000-000000000002',
      categoryId: 'cat-salmas-04',
      outletId: '550e8400-e29b-41d4-a716-446655440000',
      name: 'Edamame',
      description: 'Steamed young soybeans lightly salted.',
      price: 2500.00,
      imageUrl: 'https://via.placeholder.com/400x300',
      isAvailable: true,
    ),
    MenuItem(
      id: '2b3c4d5e-0004-0000-0000-000000000003',
      categoryId: 'cat-salmas-04',
      outletId: '550e8400-e29b-41d4-a716-446655440000',
      name: 'Miso Soup',
      description: 'Traditional Japanese miso broth with tofu and wakame seaweed.',
      price: 2000.00,
      imageUrl: 'https://via.placeholder.com/400x300',
      isAvailable: true,
    ),

    // ── Mama's Kitchen — Soups & Swallows ────────────────────────────────────
    MenuItem(
      id: '3c4d5e6f-0001-0000-0000-000000000001',
      categoryId: 'cat-mamas-01',
      outletId: '6ba7b810-9dad-11d1-80b4-00c04fd430c8',
      name: 'Egusi Soup',
      description: 'Thick melon seed soup cooked with leafy vegetables and crayfish.',
      price: 3500.00,
      imageUrl: 'https://via.placeholder.com/400x300',
      isAvailable: true,
      modifierGroups: [
        ModifierGroup(
          id: 'mg-egusi-swallow',
          menuItemId: '3c4d5e6f-0001-0000-0000-000000000001',
          name: 'Choose Swallow',
          isRequired: true,
          maxSelections: 1,
          modifiers: [
            Modifier(id: 'mod-sw-eba',       groupId: 'mg-egusi-swallow', name: 'Eba',         priceDelta: 0.00),
            Modifier(id: 'mod-sw-semo',      groupId: 'mg-egusi-swallow', name: 'Semo',        priceDelta: 0.00),
            Modifier(id: 'mod-sw-amala',     groupId: 'mg-egusi-swallow', name: 'Amala',       priceDelta: 0.00),
            Modifier(id: 'mod-sw-pounded',   groupId: 'mg-egusi-swallow', name: 'Pounded Yam', priceDelta: 300.00),
            Modifier(id: 'mod-sw-fufu',      groupId: 'mg-egusi-swallow', name: 'Fufu',        priceDelta: 0.00),
          ],
        ),
        ModifierGroup(
          id: 'mg-egusi-protein',
          menuItemId: '3c4d5e6f-0001-0000-0000-000000000001',
          name: 'Add Protein',
          isRequired: false,
          maxSelections: 2,
          modifiers: [
            Modifier(id: 'mod-pr-goat',   groupId: 'mg-egusi-protein', name: 'Goat Meat',  priceDelta: 1500.00),
            Modifier(id: 'mod-pr-beef',   groupId: 'mg-egusi-protein', name: 'Beef',        priceDelta: 1200.00),
            Modifier(id: 'mod-pr-ponmo',  groupId: 'mg-egusi-protein', name: 'Ponmo',       priceDelta: 600.00),
            Modifier(id: 'mod-pr-stock',  groupId: 'mg-egusi-protein', name: 'Stockfish',   priceDelta: 1000.00),
          ],
        ),
      ],
    ),
    MenuItem(
      id: '3c4d5e6f-0001-0000-0000-000000000002',
      categoryId: 'cat-mamas-01',
      outletId: '6ba7b810-9dad-11d1-80b4-00c04fd430c8',
      name: 'Ofe Oha',
      description: 'Traditional Igbo oha leaf soup cooked with cocoyam and assorted proteins.',
      price: 4000.00,
      imageUrl: 'https://via.placeholder.com/400x300',
      isAvailable: true,
    ),
    MenuItem(
      id: '3c4d5e6f-0001-0000-0000-000000000003',
      categoryId: 'cat-mamas-01',
      outletId: '6ba7b810-9dad-11d1-80b4-00c04fd430c8',
      name: 'Banga Soup',
      description: 'Delta-style palm nut soup with fresh fish, periwinkle, and bitter leaves.',
      price: 4500.00,
      imageUrl: 'https://via.placeholder.com/400x300',
      isAvailable: true,
    ),
    MenuItem(
      id: '3c4d5e6f-0001-0000-0000-000000000004',
      categoryId: 'cat-mamas-01',
      outletId: '6ba7b810-9dad-11d1-80b4-00c04fd430c8',
      name: 'Ogbono Soup',
      description: 'Draw soup made from ground ogbono seeds with assorted meat and dried fish.',
      price: 3800.00,
      imageUrl: 'https://via.placeholder.com/400x300',
      isAvailable: false, // seasonal
    ),
    // ── Mama's Kitchen — Rice Dishes ─────────────────────────────────────────
    MenuItem(
      id: '3c4d5e6f-0002-0000-0000-000000000001',
      categoryId: 'cat-mamas-02',
      outletId: '6ba7b810-9dad-11d1-80b4-00c04fd430c8',
      name: 'Jollof Rice',
      description: 'Mama\'s famous smoky party jollof served with your choice of protein.',
      price: 2500.00,
      imageUrl: 'https://via.placeholder.com/400x300',
      isAvailable: true,
      modifierGroups: [
        ModifierGroup(
          id: 'mg-jollof-protein',
          menuItemId: '3c4d5e6f-0002-0000-0000-000000000001',
          name: 'Add Protein',
          isRequired: false,
          maxSelections: 1,
          modifiers: [
            Modifier(id: 'mod-jr-chicken', groupId: 'mg-jollof-protein', name: 'Fried Chicken', priceDelta: 1500.00),
            Modifier(id: 'mod-jr-turkey',  groupId: 'mg-jollof-protein', name: 'Turkey',        priceDelta: 2000.00),
            Modifier(id: 'mod-jr-fish',    groupId: 'mg-jollof-protein', name: 'Fried Fish',    priceDelta: 1000.00),
          ],
        ),
      ],
    ),
    MenuItem(
      id: '3c4d5e6f-0002-0000-0000-000000000002',
      categoryId: 'cat-mamas-02',
      outletId: '6ba7b810-9dad-11d1-80b4-00c04fd430c8',
      name: 'Ofada Rice + Ayamase',
      description: 'Local ofada rice served with spicy green pepper Ayamase stew and assorted offals.',
      price: 3500.00,
      imageUrl: 'https://via.placeholder.com/400x300',
      isAvailable: true,
    ),
    MenuItem(
      id: '3c4d5e6f-0002-0000-0000-000000000003',
      categoryId: 'cat-mamas-02',
      outletId: '6ba7b810-9dad-11d1-80b4-00c04fd430c8',
      name: 'White Rice + Stew',
      description: 'Plain steamed rice with Mama\'s slow-cooked tomato beef stew.',
      price: 2200.00,
      imageUrl: 'https://via.placeholder.com/400x300',
      isAvailable: true,
    ),
    // ── Mama's Kitchen — Small Chops & Snacks ───────────────────────────────
    MenuItem(
      id: '3c4d5e6f-0003-0000-0000-000000000001',
      categoryId: 'cat-mamas-03',
      outletId: '6ba7b810-9dad-11d1-80b4-00c04fd430c8',
      name: 'Akara (6 pcs)',
      description: 'Crispy bean cake fritters, a breakfast staple.',
      price: 1000.00,
      imageUrl: 'https://via.placeholder.com/400x300',
      isAvailable: true,
    ),
    MenuItem(
      id: '3c4d5e6f-0003-0000-0000-000000000002',
      categoryId: 'cat-mamas-03',
      outletId: '6ba7b810-9dad-11d1-80b4-00c04fd430c8',
      name: 'Moin Moin',
      description: 'Steamed bean pudding with egg, fish, and peppers.',
      price: 1200.00,
      imageUrl: 'https://via.placeholder.com/400x300',
      isAvailable: true,
    ),
    // ── Mama's Kitchen — Protein Add-ons ────────────────────────────────────
    MenuItem(
      id: '3c4d5e6f-0004-0000-0000-000000000001',
      categoryId: 'cat-mamas-04',
      outletId: '6ba7b810-9dad-11d1-80b4-00c04fd430c8',
      name: 'Goat Meat (2 pieces)',
      description: 'Well-seasoned, fall-off-the-bone goat meat.',
      price: 2000.00,
      imageUrl: 'https://via.placeholder.com/400x300',
      isAvailable: true,
    ),
    MenuItem(
      id: '3c4d5e6f-0004-0000-0000-000000000002',
      categoryId: 'cat-mamas-04',
      outletId: '6ba7b810-9dad-11d1-80b4-00c04fd430c8',
      name: 'Stockfish',
      description: 'Dried and rehydrated stockfish, a Nigerian delicacy.',
      price: 1500.00,
      imageUrl: 'https://via.placeholder.com/400x300',
      isAvailable: true,
    ),

    // ── Crispy Corner — Burgers ──────────────────────────────────────────────
    MenuItem(
      id: '4d5e6f7a-0001-0000-0000-000000000001',
      categoryId: 'cat-crispy-01',
      outletId: '7c9e6679-7425-40de-944b-e07fc1f90ae7',
      name: 'Classic Beef Burger',
      description: 'Single smashed beef patty, cheese, pickles, onion, and special sauce.',
      price: 3500.00,
      imageUrl: 'https://via.placeholder.com/400x300',
      isAvailable: true,
    ),
    MenuItem(
      id: '4d5e6f7a-0001-0000-0000-000000000002',
      categoryId: 'cat-crispy-01',
      outletId: '7c9e6679-7425-40de-944b-e07fc1f90ae7',
      name: 'Double Smash Burger',
      description: 'Two crispy smashed patties, double cheese, caramelised onion, and jalapeños.',
      price: 5500.00,
      imageUrl: 'https://via.placeholder.com/400x300',
      isAvailable: true,
    ),
    MenuItem(
      id: '4d5e6f7a-0001-0000-0000-000000000003',
      categoryId: 'cat-crispy-01',
      outletId: '7c9e6679-7425-40de-944b-e07fc1f90ae7',
      name: 'Crispy Chicken Burger',
      description: 'Southern-fried chicken fillet with coleslaw and honey mustard.',
      price: 4000.00,
      imageUrl: 'https://via.placeholder.com/400x300',
      isAvailable: true,
    ),
    // ── Crispy Corner — Fried Chicken ────────────────────────────────────────
    MenuItem(
      id: '4d5e6f7a-0002-0000-0000-000000000001',
      categoryId: 'cat-crispy-02',
      outletId: '7c9e6679-7425-40de-944b-e07fc1f90ae7',
      name: '2pc Fried Chicken',
      description: 'Two pieces of crispy, juicy fried chicken with your choice of dip.',
      price: 3000.00,
      imageUrl: 'https://via.placeholder.com/400x300',
      isAvailable: true,
    ),
    MenuItem(
      id: '4d5e6f7a-0002-0000-0000-000000000002',
      categoryId: 'cat-crispy-02',
      outletId: '7c9e6679-7425-40de-944b-e07fc1f90ae7',
      name: '4pc Fried Chicken',
      description: 'Four pieces of crispy fried chicken — feed the crew.',
      price: 5500.00,
      imageUrl: 'https://via.placeholder.com/400x300',
      isAvailable: true,
    ),
    // ── Crispy Corner — Sides ────────────────────────────────────────────────
    MenuItem(
      id: '4d5e6f7a-0003-0000-0000-000000000001',
      categoryId: 'cat-crispy-03',
      outletId: '7c9e6679-7425-40de-944b-e07fc1f90ae7',
      name: 'French Fries',
      description: 'Golden crispy fries lightly seasoned with sea salt.',
      price: 1500.00,
      imageUrl: 'https://via.placeholder.com/400x300',
      isAvailable: true,
    ),
    MenuItem(
      id: '4d5e6f7a-0003-0000-0000-000000000002',
      categoryId: 'cat-crispy-03',
      outletId: '7c9e6679-7425-40de-944b-e07fc1f90ae7',
      name: 'Onion Rings',
      description: 'Battered and fried onion rings with ranch dipping sauce.',
      price: 1800.00,
      imageUrl: 'https://via.placeholder.com/400x300',
      isAvailable: true,
    ),
    // ── Crispy Corner — Shakes & Drinks ─────────────────────────────────────
    MenuItem(
      id: '4d5e6f7a-0004-0000-0000-000000000001',
      categoryId: 'cat-crispy-04',
      outletId: '7c9e6679-7425-40de-944b-e07fc1f90ae7',
      name: 'Vanilla Milkshake',
      description: 'Thick hand-spun vanilla milkshake topped with whipped cream.',
      price: 3500.00,
      imageUrl: 'https://via.placeholder.com/400x300',
      isAvailable: true,
    ),
    MenuItem(
      id: '4d5e6f7a-0004-0000-0000-000000000002',
      categoryId: 'cat-crispy-04',
      outletId: '7c9e6679-7425-40de-944b-e07fc1f90ae7',
      name: 'Chocolate Milkshake',
      description: 'Rich chocolate milkshake with dark cocoa and whipped cream.',
      price: 3500.00,
      imageUrl: 'https://via.placeholder.com/400x300',
      isAvailable: true,
    ),
  ];

  // ──────────────────────────────────────────────────────────────────────────
  // Master orders
  // ──────────────────────────────────────────────────────────────────────────

  static const List<MasterOrder> masterOrders = [
    // ── Order 1: DELIVERED ───────────────────────────────────────────────────
    MasterOrder(
      id: 'ord-master-0001-uuid-000000000001',
      userId: 'a0a1b2c3-d4e5-6789-abcd-ef0123456789',
      status: 'DELIVERED',
      totalAmount: 8200.00,
      deliveryFee: 700.00,
      deliveryAddress: '14 Adeleke Close, Lekki Phase 1, Lagos',
      createdAt: '2026-06-18T14:30:00.000Z',
      subOrders: [
        SubOrder(
          id: 'ord-sub-0001-uuid-000000000001',
          masterOrderId: 'ord-master-0001-uuid-000000000001',
          outletId: 'f47ac10b-58cc-4372-a567-0e02b2c3d479',
          outletName: 'Cactus Grill',
          status: 'DISPATCHED',
          subtotal: 7500.00,
          lineItems: [
            OrderLineItem(
              id: 'oli-0001-uuid-000000000001',
              subOrderId: 'ord-sub-0001-uuid-000000000001',
              menuItemId: '1a2b3c4d-0001-0000-0000-000000000001',
              itemNameSnapshot: 'Suya (per portion)',
              unitPrice: 2500.00,
              quantity: 1,
              selectedModifiers: {'Choose Protein': 'Beef'},
              lineTotal: 3000.00,
            ),
            OrderLineItem(
              id: 'oli-0001-uuid-000000000002',
              subOrderId: 'ord-sub-0001-uuid-000000000001',
              menuItemId: '1a2b3c4d-0002-0000-0000-000000000001',
              itemNameSnapshot: 'Jollof Rice',
              unitPrice: 2500.00,
              quantity: 2,
              selectedModifiers: {},
              lineTotal: 5000.00,
            ),
          ],
        ),
      ],
    ),

    // ── Order 2: PREPARING ───────────────────────────────────────────────────
    MasterOrder(
      id: 'ord-master-0002-uuid-000000000002',
      userId: 'a0a1b2c3-d4e5-6789-abcd-ef0123456789',
      status: 'PREPARING',
      totalAmount: 10000.00,
      deliveryFee: 700.00,
      deliveryAddress: '14 Adeleke Close, Lekki Phase 1, Lagos',
      createdAt: '2026-06-25T10:15:00.000Z',
      subOrders: [
        SubOrder(
          id: 'ord-sub-0002-uuid-000000000001',
          masterOrderId: 'ord-master-0002-uuid-000000000002',
          outletId: '6ba7b810-9dad-11d1-80b4-00c04fd430c8',
          outletName: "Mama's Kitchen",
          status: 'PREPARING',
          subtotal: 9300.00,
          lineItems: [
            OrderLineItem(
              id: 'oli-0002-uuid-000000000001',
              subOrderId: 'ord-sub-0002-uuid-000000000001',
              menuItemId: '3c4d5e6f-0001-0000-0000-000000000001',
              itemNameSnapshot: 'Egusi Soup',
              unitPrice: 3500.00,
              quantity: 1,
              selectedModifiers: {
                'Choose Swallow': 'Pounded Yam',
                'Add Protein': 'Goat Meat',
              },
              lineTotal: 5300.00,
            ),
            OrderLineItem(
              id: 'oli-0002-uuid-000000000002',
              subOrderId: 'ord-sub-0002-uuid-000000000001',
              menuItemId: '3c4d5e6f-0002-0000-0000-000000000001',
              itemNameSnapshot: 'Jollof Rice',
              unitPrice: 2500.00,
              quantity: 1,
              selectedModifiers: {'Add Protein': 'Fried Chicken'},
              lineTotal: 4000.00,
            ),
          ],
        ),
      ],
    ),

    // ── Order 3: PENDING ─────────────────────────────────────────────────────
    MasterOrder(
      id: 'ord-master-0003-uuid-000000000003',
      userId: 'a0a1b2c3-d4e5-6789-abcd-ef0123456789',
      status: 'PENDING',
      totalAmount: 14700.00,
      deliveryFee: 700.00,
      deliveryAddress: '14 Adeleke Close, Lekki Phase 1, Lagos',
      createdAt: '2026-06-25T11:45:00.000Z',
      subOrders: [
        SubOrder(
          id: 'ord-sub-0003-uuid-000000000001',
          masterOrderId: 'ord-master-0003-uuid-000000000003',
          outletId: '550e8400-e29b-41d4-a716-446655440000',
          outletName: 'Salmas',
          status: 'PENDING',
          subtotal: 14000.00,
          lineItems: [
            OrderLineItem(
              id: 'oli-0003-uuid-000000000001',
              subOrderId: 'ord-sub-0003-uuid-000000000001',
              menuItemId: '2b3c4d5e-0001-0000-0000-000000000001',
              itemNameSnapshot: 'California Roll (8 pcs)',
              unitPrice: 6500.00,
              quantity: 1,
              selectedModifiers: {'Add-ons': 'Extra Avocado'},
              lineTotal: 7300.00,
            ),
            OrderLineItem(
              id: 'oli-0003-uuid-000000000002',
              subOrderId: 'ord-sub-0003-uuid-000000000001',
              menuItemId: '2b3c4d5e-0002-0000-0000-000000000001',
              itemNameSnapshot: 'Tonkotsu Ramen',
              unitPrice: 7500.00,
              quantity: 1,
              selectedModifiers: {'Protein': 'Chashu Pork'},
              lineTotal: 7500.00,
            ),
          ],
        ),
      ],
    ),
  ];

  // ──────────────────────────────────────────────────────────────────────────
  // Notifications
  // ──────────────────────────────────────────────────────────────────────────

  static const List<AppNotification> notifications = [
    AppNotification(
      id: 'notif-uuid-000000000001',
      userId: 'a0a1b2c3-d4e5-6789-abcd-ef0123456789',
      title: 'Order Confirmed 🎉',
      body: 'Your order from Cactus Grill has been confirmed and is being prepared.',
      orderId: 'ord-master-0001-uuid-000000000001',
      isRead: true,
      createdAt: '2026-06-18T14:32:00.000Z',
    ),
    AppNotification(
      id: 'notif-uuid-000000000002',
      userId: 'a0a1b2c3-d4e5-6789-abcd-ef0123456789',
      title: "Order On Its Way 🛵",
      body: "Your order from Mama's Kitchen has been dispatched. Estimated arrival in ~25 mins.",
      orderId: 'ord-master-0002-uuid-000000000002',
      isRead: false,
      createdAt: '2026-06-25T10:45:00.000Z',
    ),
  ];

  // ──────────────────────────────────────────────────────────────────────────
  // Helpers — filter by outlet / category
  // ──────────────────────────────────────────────────────────────────────────

  static List<MenuCategory> categoriesForOutlet(String outletId) =>
      categories.where((c) => c.outletId == outletId).toList();

  static List<MenuItem> itemsForCategory(String categoryId) =>
      menuItems.where((i) => i.categoryId == categoryId).toList();

  static List<MenuItem> itemsForOutlet(String outletId) =>
      menuItems.where((i) => i.outletId == outletId).toList();

  static Outlet? outletById(String id) =>
      outlets.where((o) => o.id == id).firstOrNull;
}

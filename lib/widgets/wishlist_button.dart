import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../providers/wishlist_provider.dart';

// Tombol Wishlist dengan perubahan warna ikon & SnackBar hijau (tambah) / merah (hapus)
class WishlistButton extends StatefulWidget {
  final Product product;
  final double size;

  const WishlistButton({
    super.key,
    required this.product,
    this.size = 26,
  });

  @override
  State<WishlistButton> createState() => _WishlistButtonState();
}

class _WishlistButtonState extends State<WishlistButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 50),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wishlistProvider = context.watch<WishlistProvider>();
    final isWishlisted = wishlistProvider.isWishlist(widget.product.id);

    return ScaleTransition(
      scale: _scaleAnimation,
      child: IconButton(
        iconSize: widget.size,
        splashRadius: widget.size + 4,
        // Ketika produk ditambahkan ke wishlist, icon berubah warna (merah muda/pink atau merah hati). Sebaliknya, kembali seperti semula (abu/putih)
        icon: Icon(
          isWishlisted ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          color: isWishlisted ? const Color(0xFFE11D48) : Colors.white60,
        ),
        onPressed: () async {
          _controller.forward(from: 0.0);
          final added = await wishlistProvider.toggleWishlist(widget.product);

          if (!context.mounted) return;
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          // Ketentuan Soal: Ketika produk ditambahkan ke wishlist, icon berubah warna dan menampilkan SnackBar berwarna hijau. Sebaliknya, ketika produk dihapus dari wishlist, icon kembali seperti semula dan menampilkan SnackBar berwarna merah.
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                added
                    ? '${widget.product.title} ditambahkan ke Wishlist!'
                    : '${widget.product.title} dihapus dari Wishlist.',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600),
              ),
              backgroundColor: added
                  ? const Color(
                      0xFF16A34A) // SnackBar Berwarna HIJAU saat ditambahkan
                  : const Color(
                      0xFFDC2626), // SnackBar Berwarna MERAH saat dihapus
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          );
        },
      ),
    );
  }
}

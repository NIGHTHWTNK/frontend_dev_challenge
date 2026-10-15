import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rescu/app_config.dart';
import 'package:rescu/feature/home/widget/count_down_text.dart';
import 'package:rescu/feature/shared_widget/the_network_image.dart';
import 'package:rescu/model/deal_model.dart';
import 'package:rescu/routes/routes.dart';
import 'package:rescu/service/countdown_service.dart';

class FlashDealCard extends StatefulWidget {
  final DealModel deal;

  const FlashDealCard({
    super.key,
    required this.deal,
  });

  @override
  State<FlashDealCard> createState() => _FlashDealCardState();
}

class _FlashDealCardState extends State<FlashDealCard> {
  late final ValueListenable<DateTime> _now;
  bool _isExpired = false;

  @override
  void initState() {
    super.initState();

    _now = Get.find<CountdownService>().now;
    _isExpired = _checkExpired(_now.value);

    _now.addListener(_onTimeChanged);
  }

  bool _checkExpired(DateTime currentTime) {
    final end = widget.deal.flashSaleEndsAt;

    return end != null && !currentTime.isBefore(end.toUtc());
  }

  void _onTimeChanged() {
    final expired = _checkExpired(_now.value);

    // Rebuild the card only when its expired status changes.
    if (expired != _isExpired) {
      setState(() {
        _isExpired = expired;
      });
    }
  }

  @override
  void dispose() {
    _now.removeListener(_onTimeChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deal = widget.deal;

    return SizedBox(
      width: 200,
      child: Opacity(
        opacity: _isExpired ? 0.5 : 1,
        child: Card(
          color: _isExpired ? Colors.grey.shade200 : Colors.white,
          elevation: 0.5,
          clipBehavior: Clip.antiAlias,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          child: InkWell(
            onTap: _isExpired
                ? null
                : () => Get.toNamed(
                      Routes.dealRoute(
                        deal.id,
                        source: 'flash_rail',
                      ),
                      arguments: deal,
                    ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TheNetworkImage(
                  url: deal.imageUrl,
                  height: 90,
                  width: double.infinity,
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        deal.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        deal.storeName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text(
                            '฿${deal.price.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _isExpired
                                  ? Colors.grey
                                  : AppConfig.primaryGreen,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _isExpired
                                  ? Colors.grey.shade300
                                  : Colors.red.shade50,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: _isExpired
                                ? const Text(
                                    'Expired',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  )
                                : CountdownText(
                                    endsAt: deal.flashSaleEndsAt,
                                  ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

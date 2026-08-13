enum DeliveryType{
  bySelfDeliveryMan,
  byThirdPartyDeliveryService
}

String getDeliveryType(DeliveryType deliveryType){
  switch(deliveryType){
    case DeliveryType.bySelfDeliveryMan:
      return 'self_delivery';
    case DeliveryType.byThirdPartyDeliveryService:
      return 'third_party_delivery';
    }
}
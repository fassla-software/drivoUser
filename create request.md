/api/customer/create-request
body
{
  "carpool_route_id": "404",
  "carpool_type": "trip",
  "pickup_coordinates": "[31.2360,30.0450]",
  "destination_coordinates": "[31.2490,30.0620]",
  "min_fare": 150,
  "price": 150,
  "required_seats": 1
}
response
{
    "response_code": "default_store_200",
    "message": "Successfully added",
    "total_size": null,
    "limit": null,
    "offset": null,
    "data": {
        "trip_id": "478d11c6-848d-4c5c-9d4c-cffb9cfd7be2",
        "carpool_type": "trip",
        "payment_required": false,
        "carpool_payment_verification": null,
        "payment_accounts": [],
        "proration": null,
        "passenger_arrival_eta": "2026-05-25 08:00:00"
    },
    "errors": []
}
body
{
  "carpool_type": "travel",
  "carpool_route_id": "405",
  "boarding_point_start_id": 1,
  "boarding_point_end_id": 3,
  "min_fare": 300,
  "price": 300,
  "required_seats": 1
}
response
{
    "response_code": "default_store_200",
    "message": "Successfully added",
    "total_size": null,
    "limit": null,
    "offset": null,
    "data": {
        "trip_id": "47510a8a-1bff-4e64-b4c2-5c9c6549a24d",
        "carpool_type": "travel",
        "payment_required": true,
        "carpool_payment_verification": "pending_payment",
        "payment_accounts": [
            {
                "id": 1,
                "method": "instapay",
                "label": "drivo wallet",
                "label_ar": "محفظه دريفو",
                "account_number": "01129482829",
                "account_holder": "drivo",
                "instructions": "Drivo",
                "instructions_ar": "دريفو"
            }
        ],
        "proration": null,
        "passenger_arrival_eta": "2026-05-25 06:00:00"
    },
    "errors": []
}
body 
{
  "carpool_type": "routine",
  "carpool_route_id": "406",
  "pickup_coordinates": "[31.24, 30.05]",
  "destination_coordinates": "[31.30, 30.10]",
  "departure_time": "07:30",
  "return_time": "17:00",
  "min_fare": 2000,
  "price": 2000,
  "required_seats": 1,
  "booking_type": "all"
}
response 
{
    "response_code": "default_store_200",
    "message": "Successfully added",
    "total_size": null,
    "limit": null,
    "offset": null,
    "data": {
        "trip_id": "ad162680-d1bb-4aa2-9743-cfd01b831235",
        "carpool_type": "routine",
        "payment_required": true,
        "carpool_payment_verification": "pending_payment",
        "payment_accounts": [
            {
                "id": 1,
                "method": "instapay",
                "label": "drivo wallet",
                "label_ar": "محفظه دريفو",
                "account_number": "01129482829",
                "account_holder": "drivo",
                "instructions": "Drivo",
                "instructions_ar": "دريفو"
            }
        ],
        "proration": {
            "total_fare": 903.23,
            "fare_per_seat": 903.23,
            "remaining_days": 14,
            "total_days_in_month": 31,
            "proration_ratio": 0.4516
        },
        "passenger_arrival_eta": "2026-05-18 07:30:00"
    },
    "errors": []
}
body 
{
  "carpool_type": "north_coast",
  "carpool_route_id": "407",
  "pickup_coordinates": "[29.70, 31.10]",
  "destination_coordinates": "[29.75, 31.05]",
  "min_fare": 80,
  "price": 80,
  "required_seats": 1
}
response 
{
    "response_code": "default_store_200",
    "message": "Successfully added",
    "total_size": null,
    "limit": null,
    "offset": null,
    "data": {
        "trip_id": "8b8d3a83-495a-4c7f-b06c-81035e161c5a",
        "carpool_type": "north_coast",
        "payment_required": false,
        "carpool_payment_verification": null,
        "payment_accounts": [],
        "proration": null,
        "passenger_arrival_eta": "2026-06-01 09:00:00"
    },
    "errors": []
}

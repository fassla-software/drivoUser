endpoint /api/customer/find-rides method post
for type routine
{
  "carpool_type": "routine",
  "pickup_lat": 30.05,
  "pickup_lng": 31.24,
  "dropoff_lat": 30.10,
  "dropoff_lng": 31.30,
  "departure_time": "07:30",
  "return_time": "17:00",
  "day": "2026-05-20",
  "seats_required": 1
}
the response for this is 
{
    "response_code": "default_200",
    "message": "Successfully loaded",
    "total_size": null,
    "limit": null,
    "offset": null,
    "data": [
        {
            "route_id": 406,
            "carpool_type": "routine",
            "driver": {
                "id": "460a98c3-62ab-45c6-adab-489762cb7a3f",
                "full_name": "ahmed osman",
                "gender": "male",
                "profile_image": "2025-08-09-68976d800c73e.png"
            },
            "vehicle": {
                "id": "5e20476f-0595-46e4-b73c-18ed51a3204c",
                "category_id": "3559e0ad-8dc0-4c64-80d0-42a579d62657",
                "brand": "Citroen",
                "model": "Citroen-C5",
                "plate_number": null
            },
            "start_time": "2026-05-18 07:30:00",
            "seats_available": 2,
            "is_ac": false,
            "is_smoking_allowed": false,
            "pickup_match_point": {
                "lat": 30.05,
                "lng": 31.24
            },
            "dropoff_match_point": {
                "lat": 30.1,
                "lng": 31.3
            },
            "pickup_address": "362R+227، معروف، قسم قصر النيل، محافظة القاهرة\u202c 4272146، مصر",
            "dropoff_address": "472X+2XR الرئيس عبد السلام عارف الدقي أ، قسم الزيتون،، الزيتون القبلية، الأميرية، محافظة القاهرة\u202c 4511025، مصر",
            "price": 28000,
            "total_fare": 28000,
            "daily_price_per_seat": 2000,
            "pricing": {
                "total_fare": 28000,
                "daily_price_per_seat": 2000,
                "fare_per_seat": 28000,
                "seat_count": 1,
                "remaining_days": 14,
                "total_days_in_month": 31
            },
            "proration": {
                "total_fare": 28000,
                "daily_price_per_seat": 2000,
                "fare_per_seat": 28000,
                "seat_count": 1,
                "remaining_days": 14,
                "total_days_in_month": 31
            },
            "departure_time": "07:30:00",
            "return_time": "17:00:00",
            "passenger_arrival_eta": "2026-05-18 07:30:00",
            "boarding_point_start": null,
            "boarding_point_end": null,
            "has_music": false,
            "has_screen_entertainment": false,
            "allow_luggage": true,
            "allowed_gender": "both",
            "allowed_age_min": null,
            "allowed_age_max": null,
            "encoded_polyline": "oclvD_qt}DFQzAx@NJBMJShA]n@SbBk@S{@e@uBeAyEaB}GQg@C?G?GCIKCO@MHMJEF?@YBaDNyGOK{AO_@Gs@[Eq@KKB_C@yE?_ABq@^}BVqAf@iBrB{CdBeCr@{AVq@b@aB\\aBNmAJyANcFZqCZeBx@yChAqClAkC`@mAJy@?s@Eg@UuCE{DA_AGeBH}@bEaRL}BFi@Xy@~@sAfAuAz@eA^k@Vs@Fa@Bw@GQ[]}AgAqCwBkJoHkAeAQISAQQaBuAqCaC}CgCqAqAc@[m@[_F}DsCcCWSYWmAo@_BoAsFkEsDsCqB}AwFgEoA}@c@e@qB{AwB{AsImGuHqFoBsAqDmC}AuAm@s@eAmAkDqDqFoFwBoBeDsDs@w@oFoGiAqAUc@c@}Ay@sCsAcF{DgOwFwUoAaFeA{EyAcGrB{@zEgBn@S`Bm@`@jBpArGl@|Cf@jCeCx@iAh@eE`BeC`AeFrB_DrAg@NUB_@AiAVgC`@cATyCn@[B_BUkA]o@IaAEc@@cAPUJk@`@{BpBcAvAAD}@~AkD~FsB`D_BxBmDnEkEpFaAnAw@tAWz@c@|@Sj@Md@If@OpAW~@Sh@S\\_@JU@SAi@WKICCGW@YLY^e@F[dAgAB@L@LAJGFKBO?OESIIMEQ?IDw@`AoBlC{@f@UHg@J_AFQCUGg@_@wGcHkDyDqAyAw@q@iAgA{BkC{D_EkHyHyBaCeAy@a@QaA_@k@UoD}AiFwBAB",
            "closest_pickup": {
                "lat": 30.049960000000002,
                "lng": 31.240090000000002,
                "place_name": "362R+227، معروف، قسم قصر النيل، محافظة القاهرة\u202c 4272146، مصر"
            },
            "closest_dropoff": {
                "lat": 30.099990000000002,
                "lng": 31.300020000000004,
                "place_name": "472X+2XR الرئيس عبد السلام عارف الدقي أ، قسم الزيتون،، الزيتون القبلية، الأميرية، محافظة القاهرة\u202c 4511025، مصر"
            },
            "is_recurring": true,
            "recurring_info": {
                "recurrence_type": "repeated",
                "selected_dates": [
                    "2026-05-01",
                    "2026-05-02",
                    "2026-05-03",
                    "2026-05-04",
                    "2026-05-05",
                    "2026-05-06",
                    "2026-05-07",
                    "2026-05-08",
                    "2026-05-09",
                    "2026-05-10",
                    "2026-05-11",
                    "2026-05-12",
                    "2026-05-13",
                    "2026-05-14",
                    "2026-05-15",
                    "2026-05-16",
                    "2026-05-17",
                    "2026-05-18",
                    "2026-05-19",
                    "2026-05-20",
                    "2026-05-21",
                    "2026-05-22",
                    "2026-05-23",
                    "2026-05-24",
                    "2026-05-25",
                    "2026-05-26",
                    "2026-05-27",
                    "2026-05-28",
                    "2026-05-29",
                    "2026-05-30",
                    "2026-05-31"
                ],
                "available_dates": [
                    "2026-05-01",
                    "2026-05-02",
                    "2026-05-03",
                    "2026-05-04",
                    "2026-05-05",
                    "2026-05-06",
                    "2026-05-07",
                    "2026-05-08",
                    "2026-05-09",
                    "2026-05-10",
                    "2026-05-11",
                    "2026-05-12",
                    "2026-05-13",
                    "2026-05-14",
                    "2026-05-15",
                    "2026-05-16",
                    "2026-05-17",
                    "2026-05-18",
                    "2026-05-19",
                    "2026-05-20",
                    "2026-05-21",
                    "2026-05-22",
                    "2026-05-23",
                    "2026-05-24",
                    "2026-05-25",
                    "2026-05-26",
                    "2026-05-27",
                    "2026-05-28",
                    "2026-05-29",
                    "2026-05-30",
                    "2026-05-31"
                ]
            }
        },
        {
            "route_id": 408,
            "carpool_type": "routine",
            "driver": {
                "id": "460a98c3-62ab-45c6-adab-489762cb7a3f",
                "full_name": "ahmed osman",
                "gender": "male",
                "profile_image": "2025-08-09-68976d800c73e.png"
            },
            "vehicle": {
                "id": "5e20476f-0595-46e4-b73c-18ed51a3204c",
                "category_id": "3559e0ad-8dc0-4c64-80d0-42a579d62657",
                "brand": "Citroen",
                "model": "Citroen-C5",
                "plate_number": null
            },
            "start_time": "2026-05-18 07:30:00",
            "seats_available": 3,
            "is_ac": false,
            "is_smoking_allowed": false,
            "pickup_match_point": {
                "lat": 30.05,
                "lng": 31.24
            },
            "dropoff_match_point": {
                "lat": 30.1,
                "lng": 31.3
            },
            "pickup_address": "362R+227، معروف، قسم قصر النيل، محافظة القاهرة\u202c 4272146، مصر",
            "dropoff_address": "472X+2XR الرئيس عبد السلام عارف الدقي أ، قسم الزيتون،، الزيتون القبلية، الأميرية، محافظة القاهرة\u202c 4511025، مصر",
            "price": 1400,
            "total_fare": 1400,
            "daily_price_per_seat": 100,
            "pricing": {
                "total_fare": 1400,
                "daily_price_per_seat": 100,
                "fare_per_seat": 1400,
                "seat_count": 1,
                "remaining_days": 14,
                "total_days_in_month": 31
            },
            "proration": {
                "total_fare": 1400,
                "daily_price_per_seat": 100,
                "fare_per_seat": 1400,
                "seat_count": 1,
                "remaining_days": 14,
                "total_days_in_month": 31
            },
            "departure_time": "07:30:00",
            "return_time": "17:00:00",
            "passenger_arrival_eta": "2026-05-18 07:30:00",
            "boarding_point_start": null,
            "boarding_point_end": null,
            "has_music": false,
            "has_screen_entertainment": false,
            "allow_luggage": true,
            "allowed_gender": "both",
            "allowed_age_min": null,
            "allowed_age_max": null,
            "encoded_polyline": "oclvD_qt}DFQzAx@NJBMJShA]n@SbBk@S{@e@uBeAyEaB}GQg@C?G?GCIKCO@MHMJEF?@YBaDNyGOK{AO_@Gs@[Eq@KKB_C@yE?_ABq@^}BVqAf@iBrB{CdBeCr@{AVq@b@aB\\aBNmAJyANcFZqCZeBx@yChAqClAkC`@mAJy@?s@Eg@UuCE{DA_AGeBH}@bEaRL}BFi@Xy@~@sAfAuAz@eA^k@Vs@Fa@Bw@GQ[]}AgAqCwBkJoHkAeAQISAQQaBuAqCaC}CgCqAqAc@[m@[_F}DsCcCWSYWmAo@_BoAsFkEsDsCqB}AwFgEoA}@c@e@qB{AwB{AsImGuHqFoBsAqDmC}AuAm@s@eAmAkDqDqFoFwBoBeDsDs@w@oFoGiAqAUc@c@}Ay@sCsAcF{DgOwFwUoAaFeA{EyAcGrB{@zEgBn@S`Bm@`@jBpArGl@|Cf@jCeCx@iAh@eE`BeC`AeFrB_DrAg@NUB_@AiAVgC`@cATyCn@[B_BUkA]o@IaAEc@@cAPUJk@`@{BpBcAvAAD}@~AkD~FsB`D_BxBmDnEkEpFaAnAw@tAWz@c@|@Sj@Md@If@OpAW~@Sh@S\\_@JU@SAi@WKICCGW@YLY^e@F[dAgAB@L@LAJGFKBO?OESIIMEQ?IDw@`AoBlC{@f@UHg@J_AFQCUGg@_@wGcHkDyDqAyAw@q@iAgA{BkC{D_EkHyHyBaCeAy@a@QaA_@k@UoD}AiFwBAB",
            "closest_pickup": {
                "lat": 30.049960000000002,
                "lng": 31.240090000000002,
                "place_name": "362R+227، معروف، قسم قصر النيل، محافظة القاهرة\u202c 4272146، مصر"
            },
            "closest_dropoff": {
                "lat": 30.099990000000002,
                "lng": 31.300020000000004,
                "place_name": "472X+2XR الرئيس عبد السلام عارف الدقي أ، قسم الزيتون،، الزيتون القبلية، الأميرية، محافظة القاهرة\u202c 4511025، مصر"
            },
            "is_recurring": true,
            "recurring_info": {
                "recurrence_type": "repeated",
                "selected_dates": [
                    "2026-05-01",
                    "2026-05-02",
                    "2026-05-03",
                    "2026-05-04",
                    "2026-05-05",
                    "2026-05-06",
                    "2026-05-07",
                    "2026-05-08",
                    "2026-05-09",
                    "2026-05-10",
                    "2026-05-11",
                    "2026-05-12",
                    "2026-05-13",
                    "2026-05-14",
                    "2026-05-15",
                    "2026-05-16",
                    "2026-05-17",
                    "2026-05-18",
                    "2026-05-19",
                    "2026-05-20",
                    "2026-05-21",
                    "2026-05-22",
                    "2026-05-23",
                    "2026-05-24",
                    "2026-05-25",
                    "2026-05-26",
                    "2026-05-27",
                    "2026-05-28",
                    "2026-05-29",
                    "2026-05-30",
                    "2026-05-31"
                ],
                "available_dates": [
                    "2026-05-01",
                    "2026-05-02",
                    "2026-05-03",
                    "2026-05-04",
                    "2026-05-05",
                    "2026-05-06",
                    "2026-05-07",
                    "2026-05-08",
                    "2026-05-09",
                    "2026-05-10",
                    "2026-05-11",
                    "2026-05-12",
                    "2026-05-13",
                    "2026-05-14",
                    "2026-05-15",
                    "2026-05-16",
                    "2026-05-17",
                    "2026-05-18",
                    "2026-05-19",
                    "2026-05-20",
                    "2026-05-21",
                    "2026-05-22",
                    "2026-05-23",
                    "2026-05-24",
                    "2026-05-25",
                    "2026-05-26",
                    "2026-05-27",
                    "2026-05-28",
                    "2026-05-29",
                    "2026-05-30",
                    "2026-05-31"
                ]
            }
        }
    ],
    "errors": []
}


for type north_coast

{
  "carpool_type": "north_coast",
  "pickup_lat": 31.10,
  "pickup_lng": 29.70,
  "dropoff_lat": 31.05,
  "dropoff_lng": 29.75,
  "day": "2026-06-01",
  "seats_required": 1
}

the response for this is 
{
    "response_code": "default_200",
    "message": "Successfully loaded",
    "total_size": null,
    "limit": null,
    "offset": null,
    "data": [
        {
            "route_id": 407,
            "carpool_type": "north_coast",
            "driver": {
                "id": "460a98c3-62ab-45c6-adab-489762cb7a3f",
                "full_name": "ahmed osman",
                "gender": "male",
                "profile_image": "2025-08-09-68976d800c73e.png"
            },
            "vehicle": {
                "id": "5e20476f-0595-46e4-b73c-18ed51a3204c",
                "category_id": "3559e0ad-8dc0-4c64-80d0-42a579d62657",
                "brand": "Citroen",
                "model": "Citroen-C5",
                "plate_number": null
            },
            "start_time": "2026-06-01 09:00:00",
            "seats_available": 3,
            "is_ac": false,
            "is_smoking_allowed": false,
            "pickup_match_point": {
                "lat": 31.1,
                "lng": 29.7
            },
            "dropoff_match_point": {
                "lat": 31.05,
                "lng": 29.75
            },
            "pickup_address": "3MXX+XX قسم أول العامرية، مصر",
            "dropoff_address": "2QX2+X2 ثان العامرية، مصر",
            "price": 80,
            "monthly_price": 80,
            "proration": null,
            "departure_time": null,
            "return_time": null,
            "passenger_arrival_eta": "2026-06-01 09:00:00",
            "boarding_point_start": null,
            "boarding_point_end": null,
            "has_music": false,
            "has_screen_entertainment": false,
            "allow_luggage": true,
            "allowed_gender": "both",
            "allowed_age_min": null,
            "allowed_age_max": null,
            "encoded_polyline": "_fy|D_xgtDhnA_mArFuCj@]`@WRSnAgB|AeC~CaF`ImMpEcHtAgCrCmE`CqEfB{Cj@iA~B{GjCqH`F_Nb@sA`@iBTs@\\o@VQ~DdIxA~C`AnBjC`GJ`AtBrFp@lB\\t@N~@n@vAp@rApAdCZz@d@zALd@R`@PLXHj@ENENKHQJi@?e@K_@EKaAaAgAqA{@kAeB_D}@kBUi@SAoBcFu@cBy@sB]o@kAmC}AcDwGuMsGmMsBaEw@mBKc@Ki@Aw@N_GXmHNqMNaNFyALgAbDwRf@uDrAsIxAcJjCyPtBuM`AyGf@yC\\{A`@oA^u@dGsH~BoBNCLIR_@~@kAb@UtAg@rFsA`K_CzFqAxDaA~A]hCy@|A]jAWhFiBnBa@n@UpDgBdAu@l@k@~@k@fDcBfGwCjG{CpQoIbF_CdCiArJwEdAc@^I`GmC`L}FnMmGXO|@u@FBJAb@@TD_@L[Rm@d@mCpA{DxB{@p@WXk@bAUj@OhACzAIhBSrAWl@aAbBeAvAc@l@[n@[pAIh@Q`AKRg@b@q@\\uAn@s@h@w@fAaG`JkEzF_E~FsEtGaFlHiBrCwApB}E`HoDdFuGlJyA`C~@tA~@`AhDbFrCtE`JvN|CdFnDvFnAcA|@{@lDcDvA{Af@}@l@mAMI",
            "closest_pickup": {
                "lat": 31.087310000000002,
                "lng": 29.712480000000003,
                "place_name": "3PP7+P9H مصب ترعه الكيلو ٢١, الذراع البحري، قسم أول العامرية، محافظة الإسكندرية 5252421، مصر"
            },
            "closest_dropoff": {
                "lat": 31.049930000000003,
                "lng": 29.749950000000002,
                "place_name": "2PXX+XX ثان العامرية، مصر"
            },
            "is_recurring": false,
            "recurring_info": null
        }
    ],
    "errors": []
}

for type travel

{
  "carpool_type": "travel",
  "boarding_point_start_id": 1,
  "boarding_point_end_id": 3,
  "day": "2026-05-25",
  "seats_required": 1
}
(for this type to get the IDs you can use /api/carpool/boarding-points method get
with response 
{
    "response_code": "default_200",
    "message": "Successfully loaded",
    "total_size": null,
    "limit": null,
    "offset": null,
    "data": [
        {
            "id": 2,
            "name": "cairo-tahrir",
            "name_ar": "القاهيره-تحرير",
            "governorate": "القاهره",
            "city": "القاهره",
            "latitude": 30.0444,
            "longitude": 31.2357
        },
        {
            "id": 1,
            "name": "Giza - Remaya Square",
            "name_ar": "الجيزة - ميدان الرماية",
            "governorate": "الجيزه",
            "city": "القاهره",
            "latitude": 29.9773,
            "longitude": 31.1325
        },
        {
            "id": 3,
            "name": "Alexandria - Sidi Gaber",
            "name_ar": "الاسكنريه سيي ",
            "governorate": "الاسكندريه",
            "city": "الاسكندريه",
            "latitude": 31.2156,
            "longitude": 29.9553
        }
    ],
    "errors": []
})
the response of this endpoint 
{
    "response_code": "default_200",
    "message": "Successfully loaded",
    "total_size": null,
    "limit": null,
    "offset": null,
    "data": [
        {
            "route_id": 405,
            "carpool_type": "travel",
            "driver": {
                "id": "460a98c3-62ab-45c6-adab-489762cb7a3f",
                "full_name": "ahmed osman",
                "gender": "male",
                "profile_image": "2025-08-09-68976d800c73e.png"
            },
            "vehicle": {
                "id": "5e20476f-0595-46e4-b73c-18ed51a3204c",
                "category_id": "3559e0ad-8dc0-4c64-80d0-42a579d62657",
                "brand": "Citroen",
                "model": "Citroen-C5",
                "plate_number": null
            },
            "start_time": "2026-05-25 06:00:00",
            "seats_available": 4,
            "is_ac": true,
            "is_smoking_allowed": false,
            "pickup_match_point": {
                "lat": 29.9773,
                "lng": 31.1325
            },
            "dropoff_match_point": {
                "lat": 31.2156,
                "lng": 29.9553
            },
            "pickup_address": "Giza - Remaya Square",
            "dropoff_address": "Alexandria - Sidi Gaber",
            "price": 300,
            "monthly_price": 300,
            "proration": null,
            "departure_time": null,
            "return_time": null,
            "passenger_arrival_eta": null,
            "boarding_point_start": {
                "id": 1,
                "name": "Giza - Remaya Square",
                "name_ar": "الجيزة - ميدان الرماية",
                "governorate": "الجيزه",
                "city": "القاهره",
                "latitude": 29.9773,
                "longitude": 31.1325,
                "is_active": true,
                "sort_order": 2,
                "created_at": "2026-05-18T08:28:44.000000Z",
                "updated_at": "2026-05-18T08:28:44.000000Z"
            },
            "boarding_point_end": {
                "id": 3,
                "name": "Alexandria - Sidi Gaber",
                "name_ar": "الاسكنريه سيي ",
                "governorate": "الاسكندريه",
                "city": "الاسكندريه",
                "latitude": 31.2156,
                "longitude": 29.9553,
                "is_active": true,
                "sort_order": 3,
                "created_at": "2026-05-18T08:32:30.000000Z",
                "updated_at": "2026-05-18T08:32:30.000000Z"
            },
            "has_music": false,
            "has_screen_entertainment": false,
            "allow_luggage": true,
            "allowed_gender": "both",
            "allowed_age_min": null,
            "allowed_age_max": null,
            "encoded_polyline": "c}}uDcq_}DKMTmBsDz@yK@yByDcASeCbCaEnB{Bu@wAoBg@}C{ByIwA{C{ErEgHxGe@f@aBs@kB|F}DhN}@jEZ^dAvB@fBm@xBuJ~GaI~HuN|PyMxX{PnVyYt_@_O~PsWjOwXdO{p@pYsEpFwAtGLrb@|CvOlChPNbFJjLhBvLvEzSJbMiEvMoDjJuEnFcOrOc[`Jye@~Tqp@h]iFnFmZhn@yc@d}@wg@deAgEhK}ObYeXpf@mt@jyAqQx^cCtHmFr[eR|eA{AvOTdPnBdMlCjI|GxMx`@`s@b]`l@tGrLdEfLnAbLe@~PgB~LmHzh@eWdgBoq@huEqBvFaI`KqHlEyD|@gHl@u_@y@_m@aBmmAcHgf@u@gMpAeMpFuGxFoDbFkPpX{d@|v@}j@r~@caCnaE}cCzbEeNrTaw@p~@cx@l_A_bB~nBcKfNqCjGkCnKqBrUsM`pBsBhW_BtHuBpGo`@bcAuk@zyAuqAfgDu~BhbGoThj@iLtUiWtf@o^r{@kNh_@}j@~vAoZfv@}}@`_CuPlb@aN|a@}WlbAok@luBoqA`|Esq@xfCsQlk@a`@nu@cq@`sAq`@h}@{dAx`CcRb^eKlKyd@`d@_qB~oBakB|iB}^v^mS|Vkn@|`Aep@rcAwZfh@yWtk@mz@~iBwLpViM~Py[rX_}@jq@e}BtdB_tA|dA}K|KgQhSgRnZcA`BaRvYyJpLqf@be@g{@zw@o{@~t@e\\lXmSnSmjApmAcsChyCsoIv`JcrKbhLmmIf`JydCrlCokAfpAgZr[iEnCug@`Y{gBfbAqzBzhAwjArj@yb@rSwHlDa[`L}VxHqPzHuaAzm@eyAp}@ux@he@aR|Jes@h_@{a@nTss@h_@s[nQy`@xW{FlEoJ`LyOpScZj^gIxHeYnKkpBhp@mRlI{CrByZhXsQzP{CfCwRvGsZvI_JbC{PbG{GfFiOfPkQnR{HrG}KrDma@lB{Ga@gE}AgEkDkRyd@e^o_AwUw]{c@wl@w]qx@ac@gfAaRqd@eS_Ysb@}g@cFqFoG{DgZyHo^sI_GeCoCiCwGsKuMsUkIwQwNio@}EiRyI_Oku@g}@mTyXeL{IaJeFqGoEaZkZciAokAgxAwzAgq@sr@}AaA}@HcXdMkj@nWyMlFsBs@kGkJ_OySwXwYgVqWqEsIcRoj@yAoIsFyI{EsIkSyn@gFiQ]kLaAaE{AOiCbD_DrF_EvGoKpRsFlR{Jbg@eJbe@y@_Ay@hCqDqA~A_G|@qERoDdA{F?W{D{AgAiIb@}BQ[i@^CI",
            "closest_pickup": {
                "lat": 29.9773,
                "lng": 31.1325,
                "place_name": "X4GJ+WXQ، نزلة السمان، الهرم، محافظة الجيزة 3512201، مصر"
            },
            "closest_dropoff": {
                "lat": 31.2156,
                "lng": 29.9553,
                "place_name": "6X84+33W، نادي سموحه الرياضي، عزبة سعد، قسم سيدى جابر، محافظة الإسكندرية 5432080، مصر"
            },
            "is_recurring": false,
            "recurring_info": null
        }
    ],
    "errors": []
}

for type trip

{
  "carpool_type": "trip",
  "pickup_lat": 30.0450,
  "pickup_lng": 31.2360,
  "dropoff_lat": 30.0620,
  "dropoff_lng": 31.2490,
  "day": "2026-05-25",
  "seats_required": 1
}
the response of this endpoint will be as this 
{
    "response_code": "default_200",
    "message": "Successfully loaded",
    "total_size": null,
    "limit": null,
    "offset": null,
    "data": [
        {
            "route_id": 404,
            "carpool_type": "trip",
            "driver": {
                "id": "460a98c3-62ab-45c6-adab-489762cb7a3f",
                "full_name": "ahmed osman",
                "gender": "male",
                "profile_image": "2025-08-09-68976d800c73e.png"
            },
            "vehicle": {
                "id": "5e20476f-0595-46e4-b73c-18ed51a3204c",
                "category_id": "3559e0ad-8dc0-4c64-80d0-42a579d62657",
                "brand": "Citroen",
                "model": "Citroen-C5",
                "plate_number": null
            },
            "start_time": "2026-05-25 08:00:00",
            "seats_available": 3,
            "is_ac": false,
            "is_smoking_allowed": false,
            "pickup_match_point": {
                "lat": 30.045,
                "lng": 31.236
            },
            "dropoff_match_point": {
                "lat": 30.062,
                "lng": 31.249
            },
            "pickup_address": "11 شارع ميرت باشا، ميدان التحرير، الإسماعيلية، قسم قصر النيل، محافظة القاهرة\u202c 4272101، مصر",
            "dropoff_address": "شارع بستان المقسي،الفجاله ،قسم، 366X+QJQ، الفجالة، الأزبكية، محافظة القاهرة\u202c 4320310، مصر",
            "price": 150,
            "monthly_price": 150,
            "proration": null,
            "departure_time": null,
            "return_time": null,
            "passenger_arrival_eta": "2026-05-25 08:00:00",
            "boarding_point_start": null,
            "boarding_point_end": null,
            "has_music": false,
            "has_screen_entertainment": false,
            "allow_luggage": true,
            "allowed_gender": "both",
            "allowed_age_min": null,
            "allowed_age_max": null,
            "encoded_polyline": "gdkvD_xs}DBDkAjAy@r@i@\\gAd@gBn@s@NU@y@O{C@yC@{@Ak@W]YqAmA_C_C_B}Ak@e@c@Wk@k@iAiAyB}BwFeGoBiB}GeH{LoMyD}Dk@m@m@u@iBoBeBsBkAwAY]QYeAeC[w@Om@M[_AiCb@G",
            "closest_pickup": {
                "lat": 30.044980000000002,
                "lng": 31.235970000000002,
                "place_name": "26VP+X8F، الإسماعيلية، قسم قصر النيل، محافظة القاهرة\u202c 4272101، مصر"
            },
            "closest_dropoff": {
                "lat": 30.06218,
                "lng": 31.248960000000004,
                "place_name": "145 رمسيس، الفجالة، الأزبكية، محافظة القاهرة\u202c 4320302، مصر"
            },
            "is_recurring": false,
            "recurring_info": null
        }
    ],
    "errors": []
}
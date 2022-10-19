//
// Copyright © 2022 Robin Charlton. All rights reserved.
//

extension Marea {
    /// https://tidesandcurrents.noaa.gov/datum_options.html
    struct Datums: Decodable {
        /// Lowest Astronomical Tide.
        /// The elevation of the lowest astronomical predicted tide expected to occur at a
        /// specific tide station over the National Tidal Datum Epoch.
        let lat: Double

        /// Highest Astronomical Tide.
        /// The elevation of the highest predicted astronomical tide expected to occur at a
        /// specific tide station over the National Tidal Datum Epoch.
        let hat: Double

        /// Mean Lower Low Water.
        /// The average of the lower low water height of each tidal day observed over the
        /// National Tidal Datum Epoch. For stations with shorter series, comparison of
        /// simultaneous observations with a control tide station is made in order to derive
        /// the equivalent datum of the National Tidal Datum Epoch.
        let mllw: Double

        /// Mean Higher High Water.
        /// The average of the higher high water height of each tidal day observed over the
        /// National Tidal Datum Epoch. For stations with shorter series, comparison of
        /// simultaneous observations with a control tide station is made in order to derive
        /// the equivalent datum of the National Tidal Datum Epoch.
        let mhhw: Double

        /// Mean High Water.
        /// The average of all the high water heights observed over the National Tidal Datum
        /// Epoch. For stations with shorter series, comparison of simultaneous observations
        /// with a control tide station is made in order to derive the equivalent datum of
        /// the National Tidal Datum Epoch.
        let mhw: Double

        /// Mean Low Water.
        /// The average of all the low water heights observed over the National Tidal Datum
        /// Epoch. For stations with shorter series, comparison of simultaneous observations
        /// with a control tide station is made in order to derive the equivalent datum of
        /// the National Tidal Datum Epoch.
        let mlw: Double

        /// Mean Tide Level.
        /// The arithmetic mean of mean high water and mean low water.
        let mtl: Double

        /// Diurnal Tide Level.
        /// The arithmetic mean of mean higher high water and mean lower low water.
        let dtl: Double

        /// Great Diurnal Range.
        /// The difference in height between mean higher high water and mean lower low water.
        let gt: Double

        /// Mean Range of Tide.
        /// The difference in height between mean high water and mean low water.
        let mn: Double

        /// Mean Diurnal Low Water Inequality.
        /// One-half the average difference between the two low waters of each tidal day
        /// observed over the National Tidal Datum Epoch. It is obtained by subtracting the
        /// mean of the lower low waters from the mean of all the low waters.
        let dlq: Double

        /// Mean Diurnal High Water Inequality.
        /// One-half the average difference between the two high waters of each tidal day
        /// observed over the National Tidal Datum Epoch. It is obtained by subtracting the
        /// mean of all the high waters from the mean of the higher high waters.
        let dhq: Double

        enum CodingKeys: String, CodingKey {
            case lat = "LAT"
            case hat = "HAT"
            case mllw = "MLLW"
            case mhhw = "MHHW"
            case mhw = "MHW"
            case mlw = "MLW"
            case mtl = "MTL"
            case dtl = "DTL"
            case gt = "GT"
            case mn = "MN"
            case dlq = "DLQ"
            case dhq = "DHQ"
        }
    }
}

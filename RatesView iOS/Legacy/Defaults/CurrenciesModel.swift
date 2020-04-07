//
//  CurrenciesModel.swift
//  CoreApplication31
//
//  Created by Dennis Esie on 6/16/19.
//  Copyright © 2019 Dennis Esie. All rights reserved.
//

import Foundation

class AppModel {
    
    static let stockExchanges = ["NASDAQ"]
    static let currenciesExchanges = ["FX_IDC"]
    static let cryptoExchanges = ["BITSTAMP", "COINBASE"]
    
    static let allCryptocurenciesDictionary = [
        "BTC": "Bitcoin",
        "LTC": "Litecoin",
        "ETH": "Ethereum",
        "XRP": "Ripple"]
    
    static let europe = [""]
    static let na = [""]
    static let oceania = [""]
    static let asia = [""]
    static let sa = [""]
    static let africa = [""]
    
    static let allCurrenciesDictionary = [
        "AED": "United Arab Emirates dirham",
        "AFN": "Afghan afghani",
        "ALL": "Albanian lek",
        "AMD": "Armenian dram",
        "AOA": "Angolan kwanza",
//        "ARS": "Argentine peso",
        "AUD": "Australian dollar",
        "AWG": "Aruban florin",
        "AZN": "Azerbaijani manat",
        "BAM": "Bosnia and Herzegovina convertible mark",
        "BBD": "Barbados dollar",
        "BDT": "Bangladeshi taka",
        "BGN": "Bulgarian lev",
        "BHD": "Bahraini dinar",
        "BIF": "Burundian franc",
        "BMD": "Bermudian dollar",
        "BND": "Brunei dollar",
        "BOB": "Boliviano",
        "BRL": "Brazilian real",
        "BSD": "Bahamian dollar",
        "BTN": "Bhutanese ngultrum",
        "BWP": "Botswana pula",
        "BYN": "Belarusian ruble",
        "BZD": "Belize dollar",
        "CAD": "Canadian dollar",
        "CDF": "Congolese franc",
        "CHF": "Swiss franc",
        "CLP": "Chilean peso",
        "CNY": "Renminbi (Chinese)",
        "COP": "Colombian peso",
        "CRC": "Costa Rican colon",
        "CUC": "Cuban convertible peso",
        "CUP": "Cuban peso",
        "CVE": "Cape Verdean escudo",
        "CZK": "Czech koruna",
        "DJF": "Djiboutian franc",
        "DKK": "Danish krone",
        "DOP": "Dominican peso",
        "DZD": "Algerian dinar",
        "EGP": "Egyptian pound",
        "ERN": "Eritrean nakfa",
        "ETB": "Ethiopian birr",
        "EUR": "Euro",
        "FJD": "Fiji dollar",
        "FKP": "Falkland Islands pound",
        "GEL": "Georgian lari",
        "GHS": "Ghanaian cedi",
        "GMD": "Gambian dalasi",
        "GBP": "British pound",
        "GNF": "Guinean franc",
        "GTQ": "Guatemalan quetzal",
        "GYD": "Guyanese dollar",
        "HKD": "Hong Kong dollar",
        "HNL": "Honduran lempira",
        "HRK": "Croatian kuna",
        "HTG": "Haitian gourde",
        "HUF": "Hungarian forint",
        "IDR": "Indonesian rupiah",
        "ILS": "Israeli new shekel",
        "INR": "Indian rupee",
        "IQD": "Iraqi dinar",
        "IRR": "Iranian rial",
        "ISK": "Icelandic króna",
        "JMD": "Jamaican dollar",
        "JOD": "Jordanian dinar",
        "JPY": "Japanese yen",
        "KES": "Kenyan shilling",
        "KGS": "Kyrgyzstani som",
        "KHR": "Cambodian riel",
        "KMF": "Comoro franc",
        "KRW": "South Korean won",
        "KWD": "Kuwaiti dinar",
        "KYD": "Cayman Islands dollar",
        "KZT": "Kazakhstani tenge",
        "LAK": "Lao kip",
        "LBP": "Lebanese pound",
        "LKR": "Sri Lankan rupee",
        "LRD": "Liberian dollar",
        "LSL": "Lesotho loti",
        "LYD": "Libyan dinar",
        "MAD": "Moroccan dirham",
        "MDL": "Moldovan leu",
        "MGA": "Malagasy ariary",
        "MKD": "Macedonian denar",
        "MMK": "Myanmar kyat",
        "MNT": "Mongolian tögrög",
        "MOP": "Macanese pataca",
        "MRU": "Mauritanian ouguiya",
        "MUR": "Mauritian rupee",
        "MVR": "Maldivian rufiyaa",
        "MWK": "Malawian kwacha",
        "MXN": "Mexican peso",
        "MYR": "Malaysian ringgit",
        "MZN": "Mozambican metical",
        "NAD": "Namibian dollar",
        "NGN": "Nigerian naira",
        "NIO": "Nicaraguan córdoba",
        "NOK": "Norwegian krone",
        "NPR": "Nepalese rupee",
        "NZD": "New Zealand dollar",
        "OMR": "Omani rial",
        "PAB": "Panamanian balboa",
        "PEN": "Peruvian sol",
        "PGK": "Papua New Guinean kina",
        "PHP": "Philippine peso",
        "PKR": "Pakistani rupee",
        "PLN": "Polish złoty",
        "PYG": "Paraguayan guaraní",
        "QAR": "Qatari riyal",
        "RON": "Romanian leu",
        "RSD": "Serbian dinar",
        "RUB": "Russian ruble",
        "RWF": "Rwandan franc",
        "SAR": "Saudi riyal",
        "SBD": "Solomon Islands dollar",
        "SCR": "Seychelles rupee",
        "SDG": "Sudanese pound",
        "SEK": "Swedish krona/kronor",
        "SGD": "Singapore dollar",
        "SLL": "Sierra Leonean leone",
        "SOS": "Somali shilling",
        "SRD": "Surinamese dollar",
        "SSP": "South Sudanese pound",
        "STN": "São Tomé and Príncipe dobra",
        "SVC": "Salvadoran colón",
        "SYP": "Syrian pound",
        "SZL": "Swazi lilangeni",
        "THB": "Thai baht",
        "TJS": "Tajikistani somoni",
        "TMT": "Turkmenistan manat",
        "TND": "Tunisian dinar",
        "TOP": "Tongan paʻanga",
        "TRY": "Turkish lira",
        "TTD": "Trinidad and Tobago dollar",
        "TWD": "New Taiwan dollar",
        "TZS": "Tanzanian shilling",
        "UAH": "Ukrainian hryvnia",
        "UGX": "Ugandan shilling",
        "USD": "United States dollar",
        "UYU": "Uruguayan peso",
        "UZS": "Uzbekistan som",
        "VES": "Venezuelan bolívar soberano",
        "VND": "Vietnamese đồng",
        "VUV": "Vanuatu vatu",
        "WST": "Samoan tala",
        "YER": "Yemeni rial",
        "ZAR": "South African rand",
        "ZMW": "Zambian kwacha"]
    
    static let listOfRegions = ["AFGHANISTAN", "ANTARCTICA", "ANGOLA", "ARGENTINA", "AUSTRALIA", "AUSTRIA", "BELARUS", "BELGIUM", "BOLIVIA", "BRAZIL", "BULGARIA", "CANADA" , "CAYMAN ISLANDS", "CENTRAL AFRICAN REPUBLIC", "CHINA", "COLOMBIA", "CYPRUS", "CZECH REPUBLIC", "DENMARK", "EGYPT", "ESTONIA", "FINLAND", "FRANCE", "GERMANY", "HUNGARY", "INDIA", "INDONESIA", "ISRAEL", "ITALY", "JAPAN", "KAZAKHSTAN", "LITHUANIA", "LATVIA", "MALTA", "MEXICO", "MOLDOVA", "NEPAL", "NETHERLANDS", "NEW ZEALAND", "NORWAY", "POLAND", "PORTUGAL", "ROMANIA", "RUSSIAN FEDERATION", "SINGAPORE", "SLOVAKIA", "UKRAINE", "UNITED ARAB EMIRATES", "UNITED KINGDOM", "UNITED STATES", "VENEZUELA"]
    
    static func getCountryCode(name: String) -> String {
        switch name {
        case "AFGHANISTAN": return "AF"
        case "ANTARCTICA": return "AQ"
        case "ANGOLA": return "AO"
        case "ARGENTINA": return "AR"
        case "AUSTRALIA": return "AU"
        case "AUSTRIA": return "AT"
        case "BELARUS": return "BY"
        case "BELGIUM": return "BE"
        case "BOLIVIA": return "BO"
        case "BRAZIL": return "BR"
        case "BULGARIA": return "BG"
        case "CANADA": return "CA"
        case "CAYMAN ISLANDS": return "KY"
        case "CENTRAL AFRICAN REPUBLIC": return "CF"
        case "CHINA": return "CN"
        case "COLOMBIA": return "CO"
        case "CYPRUS": return "CY"
        case "CZECH REPUBLIC": return "CZ"
        case "DENMARK": return "DK"
        case "EGYPT": return "EG"
        case "ESTONIA": return "EE"
        case "FINLAND": return "FI"
        case "FRANCE": return "FR"
        case "GERMANY": return "DE"
        case "HUNGARY": return "HU"
        case "INDIA": return "IN"
        case "INDONESIA": return "ID"
        case "ISRAEL": return "IL"
        case "ITALY": return "IT"
        case "JAPAN": return "JP"
        case "KAZAKHSTAN": return "KZ"
        case "LITHUANIA": return "LT"
        case "LATVIA": return "LV"
        case "MALTA": return "MT"
        case "MEXICO": return "MX"
        case "MOLDOVA": return "MD"
        case "NEPAL": return "NP"
        case "NETHERLANDS": return "NL"
        case "NEW ZEALAND": return "NZ"
        case "NORWAY": return "NO"
        case "POLAND": return "PL"
        case "PORTUGAL": return "PT"
        case "ROMANIA": return "RO"
        case "RUSSIAN FEDERATION": return "RU"
        case "SINGAPORE": return "SG"
        case "SLOVAKIA": return "SK"
        case "UKRAINE": return "UA"
        case "UNITED ARAB EMIRATES": return "AE"
        case "UNITED KINGDOM ": return "GB"
        case "UNITED STATES": return "US"
        case "VENEZUELA": return "VE"
        default: return "GB"
        }
    }
    
    static func getCountryName(name: String) -> String {
        switch name {
        case "AF": return "AFGHANISTAN"
        case "AQ": return "ANTARCTICA"
        case "AO": return "ANGOLA"
        case "AR": return "ARGENTINA"
        case "AU": return "AUSTRALIA"
        case "AT": return "AUSTRIA"
        case "BY": return "BELARUS"
        case "BE": return "BELGIUM"
        case "BO": return "BOLIVIA"
        case "BR": return "BRAZIL"
        case "BG": return "BULGARIA"
        case "CA": return "CANADA"
        case "KY": return "CAYMAN ISLANDS"
        case "CF": return "CENTRAL AFRICAN REPUBLIC"
        case "CN": return "CHINA"
        case "CO": return "COLOMBIA"
        case "CY": return "CYPRUS"
        case "CZ": return "CZECH REPUBLIC"
        case "DK": return "DENMARK"
        case "EG": return "EGYPT"
        case "EE": return "ESTONIA"
        case "FI": return "FINLAND"
        case "FR": return "FRANCE"
        case "DE": return "GERMANY"
        case "HU": return "HUNGARY"
        case "IN": return "INDIA"
        case "ID": return "INDONESIA"
        case "IL": return "ISRAEL"
        case "IT": return "ITALY"
        case "JP": return "JAPAN"
        case "KZ": return "KAZAKHSTAN"
        case "LT": return "LITHUANIA"
        case "LV": return "LATVIA"
        case "MT": return "MALTA"
        case "MX": return "MEXICO"
        case "MD": return "MOLDOVA"
        case "NP": return "NEPAL"
        case "NL": return "NETHERLANDS"
        case "NZ": return "NEW ZEALAND"
        case "NO": return "NORWAY"
        case "PL": return "POLAND"
        case "PT": return "PORTUGAL"
        case "RO": return "ROMANIA"
        case "RU": return "RUSSIAN FEDERATION"
        case "SG": return "SINGAPORE"
        case "SK": return "SLOVAKIA"
        case "UA": return "UKRAINE"
        case "AE": return "UNITED ARAB EMIRATES"
        case "GB": return "UNITED KINGDOM "
        case "US": return "UNITED STATES"
        case "VE": return "VENEZUELA"
        default: return "GB"
        }
    }
}

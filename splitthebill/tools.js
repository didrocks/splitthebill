/*
 * explain how to add a javascript function. First use . for everything (C local), then in the 18n, use
 * Qt.local.decimalPoint duplication and then factorize
 */
/*
 * Display number with 2 digits
 */
function displayNum(number, currency) {
    number = parseFloat(number.toFixed(2));
    if (currency)
        number = number.toLocaleCurrencyString(Qt.locale());
    return number.toString().replace(".", Qt.locale().decimalPoint);
}

/* replace optional "," with "." unconditionnally */
function normalizeNum(input) {
    return input.replace(',', '.')
}

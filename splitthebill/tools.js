/*
 * explain how to add a javascript function. First use . for everything (C local), then in the 18n, use
 * Qt.local.decimalPoint duplication and then factorize
 */
/*
 * Display number with 2 digits
 */
function displayNum(number) {
    number = parseFloat(number.toFixed(2));
    return number.toString().replace(".", Qt.locale().decimalPoint);
}

/* replace optional "," with "." unconditionnally */
function normalizeNum(input) {
    return input.replace(',', '.')
}

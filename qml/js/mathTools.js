.pragma library

function clamp(value, minValue, maxValue) {
    return Math.max(minValue, Math.min(maxValue, value))
}

function priceWithTax(price, taxRate) {
    return (price * (1 + taxRate)).toFixed(2)
}

function levelText(value) {
    if (value < 30) {
        return "低"
    }
    if (value < 70) {
        return "中"
    }
    return "高"
}

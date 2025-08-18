/** @type {import('tailwindcss').Config} */
module.exports = {
    content: ["./src/**/*.{html,ts}"],
    safelist: ["bg-blue-400", "bg-green-400", "bg-red-400"],
    theme: {
        extend: {},
        fontFamily: {
            roboto: ["Roboto", "sans-serif"],
        },
        spacing: {
            '1-rem': 'var(--1-rem)',
            '2-rem': 'var(--2-rem)',
            '3-rem': 'var(--3-rem)',
        }
    },
    plugins: [],
};
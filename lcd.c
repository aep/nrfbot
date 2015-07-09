#include <stdint.h>
#include <string.h>
#include "nrf.h"
#include "app_error.h"
#include "twi_master.h"
#include "lcd.h"
#include "lcd_defs.h"
#include "nrf_delay.h"


void rgb_lcd_command(uint8_t value)
{
    unsigned char dta[2] = {0x80, value};
    twi_master_transfer (LCD_ADDRESS, dta, 2, true);
}

// send data
size_t rgb_lcd_write(uint8_t value)
{

    unsigned char dta[2] = {0x40, value};
// ardunio:    i2c_send_byteS(dta, 2);
    twi_master_transfer (LCD_ADDRESS, dta, 2, true);
    return 1; // assume sucess
}

void rgb_lcd_setReg(unsigned char addr, unsigned char value)
{
    unsigned char dta[2] = {addr, value};
    twi_master_transfer (RGB_ADDRESS, dta, 2, true);
//    Wire.beginTransmission(RGB_ADDRESS); // transmit to device #4
//    Wire.write(addr);
//    Wire.write(dta);
//    Wire.endTransmission();    // stop transmitting
}

void rgb_lcd_setRGB(unsigned char r, unsigned char g, unsigned char b)
{
    rgb_lcd_setReg(REG_RED,   r);
    rgb_lcd_setReg(REG_GREEN, g);
    rgb_lcd_setReg(REG_BLUE,  b);
}

const unsigned char color_define[5][3] =
{
    {255, 255, 255},             // white
    {255, 0,   0},               // red
    {0,   255, 0},               // green
    {0,   0,   255},             // blue
    {0,   255, 255}              // yellow
};

void rgb_lcd_setColor(unsigned char color)
{
    if(color > 3)return ;
    rgb_lcd_setRGB(color_define[color][0], color_define[color][1], color_define[color][2]);
}


uint8_t _displayfunction;
uint8_t _displaycontrol;
uint8_t _displaymode;

uint8_t _initialized;

uint8_t _numlines,_currline;

void rgb_lcd_display()
{
    _displaycontrol |= LCD_DISPLAYON;
    rgb_lcd_command(LCD_DISPLAYCONTROL | _displaycontrol);
}

void rgb_lcd_clear()
{
    rgb_lcd_command(LCD_CLEARDISPLAY);
}

void rgb_lcd_home()
{
    rgb_lcd_command(LCD_RETURNHOME);
    nrf_delay_ms(2);
}

void rgb_set_cursor(uint8_t col, uint8_t row)
{
    col = (row == 0 ? col | 0x80 : col | 0xc0);
    unsigned char dta[2] = {0x80, col};
    twi_master_transfer (LCD_ADDRESS, dta, 2, true);
}


void rgb_lcd_default()
{
    rgb_lcd_setRGB(230, 0, 233);
    rgb_lcd_clear();
    nrf_delay_ms(1);
    rgb_lcd_clear();
    rgb_lcd_write('O');
    rgb_lcd_write('K');
}
void rgb_lcd_connected()
{
    rgb_lcd_setRGB(0, 232, 181);
    rgb_lcd_clear();
    nrf_delay_ms(1);
    rgb_lcd_clear();
    rgb_lcd_write('C');
    rgb_lcd_write('C');
}
void rgb_lcd_sleep()
{
    rgb_lcd_setRGB(230, 0, 233);
    rgb_lcd_clear();
    rgb_lcd_write('z');
    rgb_lcd_write('Z');
    rgb_lcd_write('z');
    rgb_lcd_write('Z');
}
void rgb_lcd_error()
{
    rgb_lcd_setRGB(232, 207, 0);
    rgb_lcd_clear();
    rgb_lcd_write('E');
    rgb_lcd_write('R');
    rgb_lcd_write('R');
}

void rgb_lcd_wash_open()
{
    rgb_lcd_setRGB(71, 233, 0);
}

void rgb_lcd_wash_closed()
{
    rgb_lcd_setRGB(233, 0, 0);
}

void rgb_lcd_begin()
{
    _displayfunction = LCD_2LINE;
    nrf_delay_ms(50);
    rgb_lcd_command(LCD_FUNCTIONSET | _displayfunction);
    nrf_delay_ms(5);
    rgb_lcd_command(LCD_FUNCTIONSET | _displayfunction);
    nrf_delay_ms(2);
    rgb_lcd_command(LCD_FUNCTIONSET | _displayfunction);
    rgb_lcd_command(LCD_FUNCTIONSET | _displayfunction);

    _displaycontrol = LCD_DISPLAYON | LCD_CURSOROFF | LCD_BLINKOFF;
    rgb_lcd_display();

    rgb_lcd_clear();
    nrf_delay_ms(2);

    _displaymode = LCD_ENTRYLEFT | LCD_ENTRYSHIFTDECREMENT;
    rgb_lcd_command(LCD_ENTRYMODESET | _displaymode);

    rgb_lcd_setReg(0, 0);
    rgb_lcd_setReg(1, 0);
    rgb_lcd_setReg(0x08, 0xAA);

    nrf_delay_ms(1);
    rgb_lcd_default();
}


void rgb_lcd_init()
{
    if (!twi_master_init()) {
        APP_ERROR_CHECK(1);
    }


    rgb_lcd_begin();

}



/*
 * File:         braitenberg.c
 * Date:         September 1st, 2006
 * Description:  A controller moving various robots using the Braitenberg method.
 * Author:       Simon Blanchoud
 *
 * Copyright (c) 2008 Cyberbotics - www.cyberbotics.com
 */

#include <webots/robot.h>
#include <webots/differential_wheels.h>
#include <webots/distance_sensor.h>
#include <webots/touch_sensor.h> 
#include <string.h>
#include <stdlib.h>
#include <stdio.h>


#define MAX_DIST_SENSOR_NUMBER 16
#define MAX_TOUCH_SENSOR_NUMBER 5
#define RUN_TIME 9375
// #define RANGE (1024 / 2)
#define BOUND(x, a, b) (((x)<(a))?(a):((x)>(b))?(b):(x))
static int time_step = 0;
static double max_speed = 100.0;


WbDeviceTag* initDistanceSensors () {
    char *sensor_names[] = {"ds0", "ds1", "ds2", "ds3", "ds4", "ds5", "ds6", "ds7", "ds8", "ds9", "ds10", "ds11", "ds12", "ds13", "ds14", "ds15"};
    static WbDeviceTag sensors[MAX_DIST_SENSOR_NUMBER];

    int i;
    for (i = 0; i < MAX_DIST_SENSOR_NUMBER; i++) {
        sensors[i] = wb_robot_get_device(sensor_names[i]);
        wb_distance_sensor_enable(sensors[i], time_step);
    }

    return sensors;
}

WbDeviceTag* initTouchSensors () {
    char *sensor_names[] = {"ts_front_left", "ts_left", "ts_back", "ts_right", "ts_front_right"};
    static WbDeviceTag sensors[MAX_TOUCH_SENSOR_NUMBER];

    int i;
    for (i = 0; i < MAX_TOUCH_SENSOR_NUMBER; i++) {
        sensors[i] = wb_robot_get_device(sensor_names[i]);
        wb_touch_sensor_enable(sensors[i], time_step);
    }

    return sensors;
}

int main()
{
    wb_robot_init();
    time_step = wb_robot_get_basic_time_step();

    WbDeviceTag * touch_sensors = initTouchSensors();
    WbDeviceTag * dist_sensors = initDistanceSensors();

    FILE *file;
    // data.csv contains 23 columns, which are, in the following order:
    // 5 touch sensors input (ts_front_left, ts_left, ts_back, ts_right, ts_front_right)
    // 16 distance sensors (from ds0 to ds15)
    // 2 set wheel speed (left and right)
    file=fopen("../../../data/data2.csv", "w");
    double matrix[5][2] = {{-10, 35}, {-7, 2}, {-7, -7}, {2, -7}, {35, -10}};
    double touch_value[MAX_TOUCH_SENSOR_NUMBER];
    double dist_value[MAX_DIST_SENSOR_NUMBER];
    double speed[2] = {0,0};
    int i, j;
    int timecounter = 0;

    // while (wb_robot_step(time_step)!=-1) {
    for (timecounter = 0; timecounter < RUN_TIME; timecounter++){
        wb_robot_step(time_step);
        speed[0] = 0;
        speed[1] = 0;
        printf("Time step: %d\n", timecounter);

        for (i = 0; i < MAX_TOUCH_SENSOR_NUMBER; i++) {
            touch_value[i] = wb_touch_sensor_get_value(touch_sensors[i]);
            fprintf(file, "%.0f,", touch_value[i]);
            for(j = 0; j < 2; j++){
                speed[j] += matrix[i][j] * (1.0 - touch_value[i]);
            }
        }

        for (i = 0; i < MAX_DIST_SENSOR_NUMBER; i++) {
            dist_value[i] = wb_distance_sensor_get_value(dist_sensors[i]);
            fprintf(file, "%.2f,", dist_value[i]);
        }

        speed[i] = BOUND(speed[i], -max_speed, max_speed);
        wb_differential_wheels_set_speed(speed[0], speed[1]);
        fprintf(file, "%.1f,%.1f", speed[0], speed[1]);
        fprintf(file, "\n");
    }
    wb_robot_step(time_step);
    wb_differential_wheels_set_speed(0,0);
    // wb_differential_wheels_set_speed(0,0);
    // wb_differential_wheels_set_speed(0,0);
    fclose(file);

    return 0;
}

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
#include <webots/camera.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>

#define MAX_SENSOR_NUMBER 16
#define RANGE (1024 / 2)
#define BOUND(x, a, b) (((x)<(a))?(a):((x)>(b))?(b):(x))

static WbDeviceTag sensors[MAX_SENSOR_NUMBER], camera;
static double matrix[MAX_SENSOR_NUMBER][2];
static int num_sensors = 16;
static double range;
static int time_step = 0;
static double max_speed = 100.0;

/* We use this variable to enable a camera device if the robot has one. */
static int camera_enabled;

static void initialize()
{
    /* necessary to initialize Webots */
    wb_robot_init();

    time_step = wb_robot_get_basic_time_step();

    const char *robot_name = wb_robot_get_name();

    const char pioneer2_name[] = "ds0";
    double pioneer2_matrix[16][2] =
        { {-1, 15}, {-3, 13}, {-3, 8}, {-2, 7}, {-3, -4}, {-4, -2}, {-3, -2},
        {-1, -1}, {-1, -1}, {-2, -3}, {-2, -4}, {4, -3}, {7, -5}, {7, -3},
        {10, -2}, {11, -1} };

    char sensors_name[5];
    double (*temp_matrix)[2];

    camera_enabled = 0;
    range = RANGE;

    sprintf(sensors_name, "%s", pioneer2_name);
    temp_matrix = pioneer2_matrix;

    int i;
    for (i = 0; i < num_sensors; i++) {
        sensors[i] = wb_robot_get_device(sensors_name);
        wb_distance_sensor_enable(sensors[i], time_step);

        if ((i + 1) >= 10) {
            sensors_name[2] = '1';
            sensors_name[3]++;

            if ((i + 1) == 10) {
                sensors_name[3] = '0';
                sensors_name[4] = '\0';
            }
        } else {
            sensors_name[2]++;
        }

        int j;
        for (j = 0; j < 2; j++) {
            matrix[i][j] = temp_matrix[i][j];
        }
    }

    printf("The %s robot is initialized, it uses %d distance sensors\n", robot_name, num_sensors);
}

int main()
{
  initialize();

  while (wb_robot_step(time_step)!=-1) {
    int i, j;
    double speed[2];
    double sensors_value[MAX_SENSOR_NUMBER];

    for (i = 0; i < num_sensors; i++) {
        sensors_value[i] = wb_distance_sensor_get_value(sensors[i]);
    }

    /*
     * The Braitenberg algorithm is really simple, it simply computes the
     * speed of each wheel by summing the value of each sensor multiplied by
     * its corresponding weight. That is why each sensor must have a weight 
     * for each wheel.
     */
    for (i = 0; i < 2; i++) {
        speed[i] = 0.0;

        for (j = 0; j < num_sensors; j++) {

            /* 
             * We need to recenter the value of the sensor to be able to get
             * negative values too. This will allow the wheels to go 
             * backward too.
             */
            speed[i] += matrix[j][i] * (1.0 - (sensors_value[j] / range));
        }

        speed[i] = BOUND(speed[i], -max_speed, max_speed);
    }

    /* Set the motor speeds */
    wb_differential_wheels_set_speed(speed[0], speed[1]);
  }

  return 0;
}

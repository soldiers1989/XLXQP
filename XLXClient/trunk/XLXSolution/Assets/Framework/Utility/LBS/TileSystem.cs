//------------------------------------------------------------------------------
// <copyright company="Microsoft">
//     Copyright (c) 2006-2009 Microsoft Corporation.  All rights reserved.
// </copyright>
//------------------------------------------------------------------------------

using System;
using System.Collections.Generic;
using System.Text;

public static class TileSystem
{
    private const double EarthRadius = 6378137;
    private const double MinLatitude = -85.05112878;
    private const double MaxLatitude = 85.05112878;
    private const double MinLongitude = -180;
    private const double MaxLongitude = 180;


    /// <summary>
    /// Clips a number to the specified minimum and maximum values.
    /// </summary>
    /// <param name="n">The number to clip.</param>
    /// <param name="minValue">Minimum allowable value.</param>
    /// <param name="maxValue">Maximum allowable value.</param>
    /// <returns>The clipped value.</returns>
    private static double Clip(double n, double minValue, double maxValue)
    {
        return Math.Min(Math.Max(n, minValue), maxValue);
    }



    /// <summary>
    /// Determines the map width and height (in pixels) at a specified level
    /// of detail.
    /// </summary>
    /// <param name="levelOfDetail">Level of detail, from 1 (lowest detail)
    /// to 23 (highest detail).</param>
    /// <returns>The map width and height in pixels.</returns>
    public static uint MapSize(int levelOfDetail)
    {
        return (uint)256 << levelOfDetail;
    }



    /// <summary>
    /// Determines the ground resolution (in meters per pixel) at a specified
    /// latitude and level of detail.
    /// </summary>
    /// <param name="latitude">Latitude (in degrees) at which to measure the
    /// ground resolution.</param>
    /// <param name="levelOfDetail">Level of detail, from 1 (lowest detail)
    /// to 23 (highest detail).</param>
    /// <returns>The ground resolution, in meters per pixel.</returns>
    public static double GroundResolution(double latitude, int levelOfDetail)
    {
        latitude = Clip(latitude, MinLatitude, MaxLatitude);
        return Math.Cos(latitude * Math.PI / 180) * 2 * Math.PI * EarthRadius / MapSize(levelOfDetail);
    }


    /// <summary>
    /// Determines the map scale at a specified latitude, level of detail,
    /// and screen resolution.
    /// </summary>
    /// <param name="latitude">Latitude (in degrees) at which to measure the
    /// map scale.</param>
    /// <param name="levelOfDetail">Level of detail, from 1 (lowest detail)
    /// to 23 (highest detail).</param>
    /// <param name="screenDpi">Resolution of the screen, in dots per inch.</param>
    /// <returns>The map scale, expressed as the denominator N of the ratio 1 : N.</returns>
    public static double MapScale(double latitude, int levelOfDetail, int screenDpi)
    {
        return GroundResolution(latitude, levelOfDetail) * screenDpi / 0.0254;
    }



    /// <summary>
    /// Converts a point from latitude/longitude WGS-84 coordinates (in degrees)
    /// into pixel XY coordinates at a specified level of detail.
    /// </summary>
    /// <param name="latitude">Latitude of the point, in degrees.</param>
    /// <param name="longitude">Longitude of the point, in degrees.</param>
    /// <param name="levelOfDetail">Level of detail, from 1 (lowest detail)
    /// to 23 (highest detail).</param>
    /// <param name="pixelX">Output parameter receiving the X coordinate in pixels.</param>
    /// <param name="pixelY">Output parameter receiving the Y coordinate in pixels.</param>
    public static void LatLongToPixelXY(double latitude, double longitude, int levelOfDetail, out int pixelX, out int pixelY)
    {
        latitude = Clip(latitude, MinLatitude, MaxLatitude);
        longitude = Clip(longitude, MinLongitude, MaxLongitude);

        double x = (longitude + 180) / 360;
        double sinLatitude = Math.Sin(latitude * Math.PI / 180);
        double y = 0.5 - Math.Log((1 + sinLatitude) / (1 - sinLatitude)) / (4 * Math.PI);

        uint mapSize = MapSize(levelOfDetail);
        pixelX = (int)Clip(x * mapSize + 0.5, 0, mapSize - 1);
        pixelY = (int)Clip(y * mapSize + 0.5, 0, mapSize - 1);
    }



    /// <summary>
    /// Converts a pixel from pixel XY coordinates at a specified level of detail
    /// into latitude/longitude WGS-84 coordinates (in degrees).
    /// </summary>
    /// <param name="pixelX">X coordinate of the point, in pixels.</param>
    /// <param name="pixelY">Y coordinates of the point, in pixels.</param>
    /// <param name="levelOfDetail">Level of detail, from 1 (lowest detail)
    /// to 23 (highest detail).</param>
    /// <param name="latitude">Output parameter receiving the latitude in degrees.</param>
    /// <param name="longitude">Output parameter receiving the longitude in degrees.</param>
    public static void PixelXYToLatLong(int pixelX, int pixelY, int levelOfDetail, out double latitude, out double longitude)
    {
        double mapSize = MapSize(levelOfDetail);
        double x = (Clip(pixelX, 0, mapSize - 1) / mapSize) - 0.5;
        double y = 0.5 - (Clip(pixelY, 0, mapSize - 1) / mapSize);

        latitude = 90 - 360 * Math.Atan(Math.Exp(-y * 2 * Math.PI)) / Math.PI;
        longitude = 360 * x;
    }

    /// <summary>
    /// 内部调用 LatLongToPixelXY 方法 和 PixelXYToTileXY 方法转换
    /// </summary>
    /// <param name="latitude"></param>
    /// <param name="longitude"></param>
    /// <param name="levelOfDetail"></param>
    /// <param name="tileX"></param>
    /// <param name="tileY"></param>
    public static void LatLongToTileXY(double latitude, double longitude, int levelOfDetail, out int tileX, out int tileY)
    {
        int pixelX; int pixelY;
        LatLongToPixelXY(latitude, longitude, levelOfDetail, out pixelX, out pixelY);
        PixelXYToTileXY(pixelX, pixelY, out tileX, out tileY);
    }

    /// <summary>
    /// Converts pixel XY coordinates into tile XY coordinates of the tile containing
    /// the specified pixel.
    /// </summary>
    /// <param name="pixelX">Pixel X coordinate.</param>
    /// <param name="pixelY">Pixel Y coordinate.</param>
    /// <param name="tileX">Output parameter receiving the tile X coordinate.</param>
    /// <param name="tileY">Output parameter receiving the tile Y coordinate.</param>
    public static void PixelXYToTileXY(int pixelX, int pixelY, out int tileX, out int tileY)
    {
        tileX = pixelX / 256;
        tileY = pixelY / 256;
    }



    /// <summary>
    /// Converts tile XY coordinates into pixel XY coordinates of the upper-left pixel
    /// of the specified tile.
    /// </summary>
    /// <param name="tileX">Tile X coordinate.</param>
    /// <param name="tileY">Tile Y coordinate.</param>
    /// <param name="pixelX">Output parameter receiving the pixel X coordinate.</param>
    /// <param name="pixelY">Output parameter receiving the pixel Y coordinate.</param>
    public static void TileXYToPixelXY(int tileX, int tileY, out int pixelX, out int pixelY)
    {
        pixelX = tileX * 256;
        pixelY = tileY * 256;
    }


    /// <summary>
    /// 内部调用 TileXYToPixelXY 方法 和 PixelXYToLatLong 方法转换
    /// </summary>
    /// <param name="tileX"></param>
    /// <param name="tileY"></param>
    /// <param name="levelOfDetail"></param>
    /// <param name="latitude"></param>
    /// <param name="longitude"></param>
    public static void TileXYToLatLong(int tileX, int tileY, int levelOfDetail, out double latitude, out double longitude)
    {
        int pixelX;
        int pixelY;
        TileXYToPixelXY(tileX, tileY, out pixelX, out pixelY);
        PixelXYToLatLong(pixelX, pixelY, levelOfDetail, out latitude, out longitude);
    }

    /// <summary>
    /// Converts tile XY coordinates into a QuadKey at a specified level of detail.
    /// </summary>
    /// <param name="tileX">Tile X coordinate.</param>
    /// <param name="tileY">Tile Y coordinate.</param>
    /// <param name="levelOfDetail">Level of detail, from 1 (lowest detail)
    /// to 23 (highest detail).</param>
    /// <returns>A string containing the QuadKey.</returns>
    public static string TileXYToQuadKey(int tileX, int tileY, int levelOfDetail)
    {
        StringBuilder quadKey = new StringBuilder();
        for (int i = levelOfDetail; i > 0; i--)
        {
            char digit = '0';
            int mask = 1 << (i - 1);
            if ((tileX & mask) != 0)
            {
                digit++;
            }
            if ((tileY & mask) != 0)
            {
                digit++;
                digit++;
            }
            quadKey.Append(digit);
        }
        return quadKey.ToString();
    }



    /// <summary>
    /// Converts a QuadKey into tile XY coordinates.
    /// </summary>
    /// <param name="quadKey">QuadKey of the tile.</param>
    /// <param name="tileX">Output parameter receiving the tile X coordinate.</param>
    /// <param name="tileY">Output parameter receiving the tile Y coordinate.</param>
    /// <param name="levelOfDetail">Output parameter receiving the level of detail.</param>
    public static void QuadKeyToTileXY(string quadKey, out int tileX, out int tileY, out int levelOfDetail)
    {
        tileX = tileY = 0;
        levelOfDetail = quadKey.Length;
        for (int i = levelOfDetail; i > 0; i--)
        {
            int mask = 1 << (i - 1);
            switch (quadKey[levelOfDetail - i])
            {
                case '0':
                    break;

                case '1':
                    tileX |= mask;
                    break;

                case '2':
                    tileY |= mask;
                    break;

                case '3':
                    tileX |= mask;
                    tileY |= mask;
                    break;

                default:
                    throw new ArgumentException("Invalid QuadKey digit sequence.");
            }
        }
    }


    #region 2点经纬度之间的距离

    private static double rad(double d)
    {
        return d * Math.PI / 180.0;
    }

    public static double GetDistance(double lat1, double lng1, double lat2, double lng2)
    {
        double radLat1 = rad(lat1);
        double radLat2 = rad(lat2);
        double a = radLat1 - radLat2;
        double b = rad(lng1) - rad(lng2);
        double s = 2 * Math.Asin(Math.Sqrt(Math.Pow(Math.Sin(a / 2), 2) +
         Math.Cos(radLat1) * Math.Cos(radLat2) * Math.Pow(Math.Sin(b / 2), 2)));
        s = s * EarthRadius;
        s = Math.Round(s * 10000) / 10000;
        return s;
    }

    /// <summary>
    /// 经纬度和偏移计算出新的经纬度
    /// </summary>
    /// <param name="latidute">纬度</param>
    /// <param name="longitude">经度</param>
    /// <param name="offsetX">经度偏移</param>
    /// <param name="offsetY">纬度偏移</param>
    /// <param name="newLatidute">新的经度</param>
    /// <param name="newLongitude">新的纬度</param>
    public static void LatLongAndOffsetToLatLong(double latidute, double longitude, double offsetX, double offsetY, out double newLatidute, out double newLongitude)
    {
        newLatidute = latidute + offsetY * 180.0 / (Math.PI * EarthRadius);
        newLongitude = longitude + offsetX * 180.0 / (Math.PI * Math.Cos(newLatidute) * EarthRadius);
    }

    #endregion

    /// <summary>
    /// 获取街区信息
    /// </summary>
    /// <param name="top_lon"></param>
    /// <param name="top_lat"></param>
    /// <param name="bottom_lon"></param>
    /// <param name="bottom_lat"></param>
    /// <returns></returns>
    public static List<TilePoint> GenerateStreetMapGrid(double top_lon, double top_lat, double bottom_lon, double bottom_lat, int level)
    {
        List<TilePoint> tempList = new List<TilePoint>();
        TilePoint start_tile_point = new TilePoint();
        TilePoint end_tile_point = new TilePoint();

        LatLongToTileXY(top_lat, top_lon, level, out start_tile_point.TileX, out start_tile_point.TileY);
        LatLongToTileXY(bottom_lat, bottom_lon, level, out end_tile_point.TileX, out end_tile_point.TileY);

        int x_length = UnityEngine.Mathf.Abs(start_tile_point.TileX - end_tile_point.TileX);
        int y_length = UnityEngine.Mathf.Abs(start_tile_point.TileY - end_tile_point.TileY);

        int x_start = Math.Min(start_tile_point.TileX, end_tile_point.TileX);
        int y_start = Math.Min(start_tile_point.TileY, end_tile_point.TileY);

        for (int y = 0; y <= y_length; y++)
        {
            int y_tile = y_start + y;
            for (int x = 0; x <= x_length; ++x)
            {
                int x_tile = x_start + x;
                TilePoint tempPoint = new TilePoint();
                tempPoint.TileX = x_tile;
                tempPoint.TileY = y_tile;
                tempPoint.QuadKey = TileXYToQuadKey(tempPoint.TileX, tempPoint.TileY, level);
                tempList.Add(tempPoint);
            }
        }

        return tempList;
    }

    public static List<TilePoint> GenerateStreetMapGrid(double lon, double lat, int fromLevel, int toLevel)
    {
        double length = Math.Pow(2, toLevel - fromLevel) - 1;
        int tileX; int tileY;
        LatLongToTileXY(lat, lon, toLevel, out tileX, out tileY);
        List<TilePoint> tempList = new List<TilePoint>();


        for (int y = 0; y <= length; y++)
        {
            int y_tile = tileY + y;
            for (int x = 0; x <= length; ++x)
            {
                int x_tile = tileX + x;
                TilePoint tempPoint = new TilePoint();
                tempPoint.TileX = x_tile;
                tempPoint.TileY = y_tile;
                tempPoint.QuadKey = TileXYToQuadKey(tempPoint.TileX, tempPoint.TileY, toLevel);
                tempList.Add(tempPoint);
            }
        }
        return tempList;
    }

    private static int COUNT_PER_LEVEL = 4;
    public static void GetLevelQuadkeys(string quadKey, int fromLevel, int toLevel, List<TilePoint> quadkeylist)
    {
        if (fromLevel + 1 > toLevel)
        {
            return;
        }

        for (int i = 0; i < COUNT_PER_LEVEL; i++)
        {
            TilePoint tempTilePoint = new TilePoint();
            tempTilePoint.QuadKey = string.Format("{0}{1}", quadKey, i);
            if ((fromLevel + 1) != toLevel)
            {
                GetLevelQuadkeys(tempTilePoint.QuadKey, fromLevel + 1, toLevel, quadkeylist);
            }
            else
            {
                int tileX; int tileY;
                int level;
                QuadKeyToTileXY(tempTilePoint.QuadKey, out tileX, out tileY, out level);
                UnityEngine.Debug.Log(" le " + level);
                tempTilePoint.TileX = tileY;
                tempTilePoint.TileY = tileY;
                quadkeylist.Add(tempTilePoint);
            }
        }
    }

    public class TilePoint
    {
        public int TileX;

        public int TileY;

        public string QuadKey;
    }
}

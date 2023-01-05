//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/utils/math/Math.sol";
import "./Utilities.sol";

library DelaunayTriangulation {

    struct Point {
        uint256 x;
        uint256 y;
    }

    struct Delaunay {
        Point[] points;
        uint256 triangleCounter;
        uint256[3][] triangles;
    }

    /**
     * Create a Delaunay triangulation of a set of points.
     */
    function createDelaunay(Point[] memory points) public pure returns (Delaunay memory delaunay) {
        
        delaunay.points = points;

        // Sort the points by x-coordinate
        bubbleSort(delaunay.points);

        // Initialize the isDeleted array
        bool[] memory isDeleted = new bool[](delaunay.points.length);

        // Initialize the triangle counter
        delaunay.triangleCounter = 0;

        for (uint256 i = 0; i < delaunay.points.length; i++) {
            isDeleted[i] = false;
        }

        // For each pair of points (i, j) in the points array
        for (uint256 i = 0; i < delaunay.points.length; i++) {
            for (uint256 j = i + 1; j < delaunay.points.length; j++) {
                if (!isDeleted[i] && !isDeleted[j]) {
                    Point memory a = delaunay.points[i];
                    Point memory b = delaunay.points[j];

                    // Initialize the bounding box of the triangle (a, b, k)
                    uint256 xMin = min(a.x, b.x);
                    uint256 xMax = max(a.x, b.x);
                    uint256 yMin = min(a.y, b.y);
                    uint256 yMax = max(a.y, b.y);

                    for (uint256 k = 0; k < delaunay.points.length; k++) {
                        // If the points i, j, and k form a triangle that encloses no other points
                        if ((k != i) && (k != j) && isEnclosingTriangle(delaunay, a, b, delaunay.points[k], xMin, xMax, yMin, yMax)) {
                            // Add the triangle (i, j, k) to the triangles array
                            delaunay.triangles[delaunay.triangleCounter] = [i, j, k];

                            delaunay.triangleCounter++;

                            isDeleted[k] = true;
                        }
                    }
                }
            }
        }
    }

    function getDelaunayPathData(Delaunay memory delaunay) public pure returns (string memory) {
        string memory pathData = "";

        for (uint256 i = 0; i < delaunay.triangles.length; i++) {
            // Get the indices of the points that make up the triangle
            uint256 i1 = delaunay.triangles[i][0];
            uint256 i2 = delaunay.triangles[i][1];
            uint256 i3 = delaunay.triangles[i][2];

            // Get the points that make up the triangle
            Point memory p1 = delaunay.points[i1];
            Point memory p2 = delaunay.points[i2];
            Point memory p3 = delaunay.points[i3];

            // Add the path data for the triangle to the path data string
            pathData = string.concat(
                pathData,
                "M ",
                utils.uintToStr(p1.x),
                " ",
                utils.uintToStr(p1.y),
                " L ",
                utils.uintToStr(p2.x),
                " ",
                utils.uintToStr(p2.y),
                " L ",
                utils.uintToStr(p3.x),
                " ",
                utils.uintToStr(p3.y),
                " Z"
            );
        }

        // Return the path data string
        return pathData;
    }

    /**
     * Determine whether the triangle (a, b, c) encloses any other points
     */
    function isEnclosingTriangle(Delaunay memory delaunay, Point memory a, Point memory b, Point memory c, uint256 xMin, uint256 xMax, uint256 yMin, uint256 yMax) internal pure returns (bool) {
        // If the bounding box of the triangle (a, b, c) does not enclose any other points
        if ((xMin < c.x) && (c.x < xMax) && (yMin < c.y) && (c.y < yMax)) {
            return false;
        }

        // For each point p in the points array
        for (uint256 i = 0; i < delaunay.points.length; i++) {
            Point memory p = delaunay.points[i];

            if ((p.x != a.x || p.y != a.y) && (p.x != b.x || p.y != b.y) && (p.x != c.x || p.y != c.y)) {
                // If p is inside triangle a, b, c
                if (isInsideTriangle(a, b, c, p)) {
                    return false;
                }
            }
        }

        return true;
    }

    /**
     * Determine whether a point p is inside the triangle (a, b, c).
     */
    function isInsideTriangle(Point memory a, Point memory b, Point memory c, Point memory p) internal pure returns (bool) {
        uint256 area1 = triangleArea(a, b, p);
        uint256 area2 = triangleArea(a, p, c);
        uint256 area3 = triangleArea(p, b, c);

        // Check if sum of areas of triangles (a, b, p), (a, p, c), and (p, b, c) is equal to the area of the triangle (a, b, c)
        if (area1 + area2 + area3 == triangleArea(a, b, c)) {

            return true;
        }

        return false;
    }

    /**
     * Compute area of a triangle given the coordinates of its three vertices
     */
    function triangleArea(Point memory a, Point memory b, Point memory c) internal pure returns (uint256) {
        // Compute the lengths of the sides of the triangle
        uint256 side1 = euclideanDistance(a, b);
        uint256 side2 = euclideanDistance(a, c);
        uint256 side3 = euclideanDistance(b, c);

        // Compute the semi-perimeter of the triangle
        uint256 semiPerimeter = (side1 + side2 + side3) / 2;

        // Compute and return the area of the triangle
        return sqrt(semiPerimeter * (semiPerimeter - side1) * (semiPerimeter - side2) * (semiPerimeter - side3));
        
    }
    /**
     * Compute the Euclidean distance between two points
     */
    function euclideanDistance(Point memory a, Point memory b) internal pure returns (uint256) {
        // Compute the differences between the x-coordinates and y-coordinates of the points
        uint256 dx = a.x - b.x;
        uint256 dy = a.y - b.y;

        // Return the Euclidean distance between the points
        return sqrt(dx * dx + dy * dy);
    }

    /**
     * Sort an array of points by x-coordinate
     */
    function bubbleSort(Point[] memory points) internal pure {
        // Initialize the flag that indicates whether the array is sorted
        bool isSorted = false;

        // While the array is not sorted
        while (!isSorted) {

            isSorted = true;

            // For each pair of adjacent elements in the array
            for (uint256 i = 0; i < points.length - 1; i++) {
                // If the x-coordinate of the second element is less than the x-coordinate of the first element
                if (sortPointsByX(points[i + 1], points[i])) {
                    // Swap the elements
                    Point memory temp = points[i];
                    points[i] = points[i + 1];
                    points[i + 1] = temp;

                    isSorted = false;
                }
            }
        }
    }

    /**
     * Helper function to sort points by x-coordinate.
     */
    function sortPointsByX(Point memory a, Point memory b) internal pure returns (bool) {
        return (a.x < b.x);
    }

    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded down.
     *
     * Inspired by Henry S. Warren, Jr.'s "Hacker's Delight" (Chapter 11).
     */
    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 result = 1 << (log2(a) >> 1);

        unchecked {
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            return min(result, a / result);
        }
    }

        /**
     * @dev Return the log in base 2, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 128;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 64;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 32;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 16;
            }
            if (value >> 8 > 0) {
                value >>= 8;
                result += 8;
            }
            if (value >> 4 > 0) {
                value >>= 4;
                result += 4;
            }
            if (value >> 2 > 0) {
                value >>= 2;
                result += 2;
            }
            if (value >> 1 > 0) {
                result += 1;
            }
        }
        return result;
    }
}
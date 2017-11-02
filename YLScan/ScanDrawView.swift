//
//  ScanDrawView.swift
//  ScanDemo
//
//  Created by 李 on 2017/10/27.
//  Copyright © 2017年 Archerycn. All rights reserved.
//

import UIKit

class ScanDrawView: UIView {
    
    var retangleLeft: CGFloat = 30
    var centerYup: CGFloat = 20
    // 相框角的宽度和高度
    var wAngle: CGFloat = 20
    var hAngle: CGFloat = 20
    // 4个角的 线的宽度
    let linewidthAngle: CGFloat = 6
    // 中间矩阵线的颜色
    var lineAngleColor = UIColor.black
    // 矩阵四个角的颜色
    var cornerColor = UIColor.black
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        drawScanRect()
    }
    
    //MARK:----- 绘制扫码效果-----
    func drawScanRect()  {
        
        let sizeRetangle = CGSize(width: frame.width - 2 * retangleLeft, height: frame.width - 2 * retangleLeft)
        let YRetangle = frame.height / 2 - sizeRetangle.height / 2 - centerYup
        let YRetangleBottom = YRetangle + sizeRetangle.height
        let XRetangleRight = retangleLeft + sizeRetangle.width
        
        let context = UIGraphicsGetCurrentContext()!
        //非扫码区域半透明
        //设置非识别区域颜色
        
        context.setFillColor(UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor)
        //填充矩形
        //扫码区域上面填充
        var rect = CGRect(x: 0, y: 0, width: frame.size.width, height: YRetangle)
        context.fill(rect)
        
        //扫码区域左边填充
        rect = CGRect(x: 0, y: YRetangle, width: retangleLeft, height: sizeRetangle.height)
        context.fill(rect)
        
        //扫码区域右边填充
        rect = CGRect(x: XRetangleRight, y: YRetangle, width: retangleLeft,height: sizeRetangle.height)
        context.fill(rect)
        
        //扫码区域下面填充
        rect = CGRect(x: 0, y: YRetangleBottom, width: frame.width,height: frame.height - YRetangleBottom)
        context.fill(rect)
        //执行绘画
        
        context.strokePath()
        
        //中间画矩形(正方形)
        context.setStrokeColor(lineAngleColor.cgColor)
        context.setLineWidth(1)
        context.addRect(CGRect(x: retangleLeft, y: YRetangle, width: sizeRetangle.width, height: sizeRetangle.height))
        context.strokePath()
        
        //画矩形框4格外围相框角
        //画扫码矩形以及周边半透明黑色坐标参数
        var diffAngle: CGFloat = linewidthAngle / 3
        //框外面4个角，与框有缝隙
        diffAngle = linewidthAngle / 2
        //框4个角 在线上加4个角效果
        diffAngle = linewidthAngle / 2
        //与矩形框重合
        diffAngle = 0
        
        context.setStrokeColor(cornerColor.cgColor);
        
        // Draw them with a 2.0 stroke width so they are a bit more visible.
        context.setLineWidth(CGFloat(linewidthAngle))
        
        let leftX = retangleLeft - diffAngle
        let topY = YRetangle - diffAngle
        let rightX = retangleLeft + sizeRetangle.width + diffAngle
        let bottomY = YRetangleBottom + diffAngle
        
        //左上角水平线
        context.move(to: CGPoint(x: leftX - linewidthAngle / 2, y: topY))
        context.addLine(to: CGPoint(x: leftX + wAngle, y: topY))
        
        //左上角垂直线
        context.move(to: CGPoint(x: leftX, y: topY - linewidthAngle / 2))
        context.addLine(to: CGPoint(x: leftX, y: topY+hAngle))
        
        //左下角水平线
        context.move(to: CGPoint(x: leftX-linewidthAngle / 2, y: bottomY))
        context.addLine(to: CGPoint(x: leftX + wAngle, y: bottomY))
        
        //左下角垂直线
        context.move(to: CGPoint(x: leftX, y: bottomY + linewidthAngle / 2))
        context.addLine(to: CGPoint(x: leftX, y: bottomY - hAngle))
        
        //右上角水平线
        context.move(to: CGPoint(x: rightX + linewidthAngle / 2, y: topY))
        context.addLine(to: CGPoint(x: rightX - wAngle, y: topY))
        
        //右上角垂直线
        context.move(to: CGPoint(x: rightX, y: topY - linewidthAngle / 2))
        context.addLine(to: CGPoint(x: rightX, y: topY + hAngle))
        
        //右下角水平线
        context.move(to: CGPoint(x: rightX+linewidthAngle / 2, y: bottomY))
        context.addLine(to: CGPoint(x: rightX - wAngle, y: bottomY))
        
        //右下角垂直线
        context.move(to: CGPoint(x: rightX, y: bottomY + linewidthAngle / 2))
        context.addLine(to: CGPoint(x: rightX, y: bottomY - hAngle))
        
        context.strokePath()
    }

}

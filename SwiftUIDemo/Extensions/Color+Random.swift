import SwiftUI

/**
 * 颜色扩展 - 提供随机颜色和预定义的美观配色方案
 *
 * Color Extension - Provides random colors and predefined beautiful color schemes
 *
 * 本文件定义了一组精心挑选的颜色，这些颜色在视觉上和谐且适合现代 UI 设计。
 * 颜色选择基于 Material Design 和 iOS Human Interface Guidelines 的建议。
 *
 * This file defines a carefully selected set of colors that are visually harmonious and suitable
 * for modern UI design. Color selection is based on recommendations from Material Design and
 * iOS Human Interface Guidelines.
 *
 * 设计理念：
 * 1. 颜色需要在浅色和深色模式下都好看
 * 2. 颜色之间要有足够的对比度
 * 3. 避免过于鲜艳刺眼的颜色
 * 4. 保持整体的视觉和谐
 *
 * Design Philosophy:
 * 1. Colors need to look good in both light and dark modes
 * 2. Colors should have sufficient contrast between them
 * 3. Avoid overly bright and harsh colors
 * 4. Maintain overall visual harmony
 */

extension Color {

    // MARK: - Predefined Beautiful Colors / 预定义的美观颜色

    /**
     * 精心挑选的配色方案 - 适合各种 UI 场景
     *
     * Carefully selected color schemes - Suitable for various UI scenarios
     *
     * 这些颜色经过测试，在各种背景下都有良好的可读性和美观度。
     *
     * These colors have been tested and have good readability and aesthetics on various backgrounds.
     */
    static let beautifulColors: [Color] = [
        // 蓝色系 - 专业、可信赖
        // Blue series - Professional, trustworthy
        Color(red: 0.00, green: 0.48, blue: 1.00),  // Bright Blue / 明亮蓝
        Color(red: 0.00, green: 0.60, blue: 0.86),  // Sky Blue / 天空蓝
        Color(red: 0.25, green: 0.51, blue: 0.77),  // Soft Blue / 柔和蓝

        // 紫色系 - 创新、优雅
        // Purple series - Innovative, elegant
        Color(red: 0.58, green: 0.44, blue: 0.86),  // Lavender / 薰衣草紫
        Color(red: 0.69, green: 0.32, blue: 0.87),  // Royal Purple / 皇家紫
        Color(red: 0.56, green: 0.27, blue: 0.68),  // Deep Purple / 深紫

        // 绿色系 - 生机、成长
        // Green series - Vitality, growth
        Color(red: 0.30, green: 0.69, blue: 0.31),  // Fresh Green / 清新绿
        Color(red: 0.18, green: 0.80, blue: 0.44),  // Emerald / 翡翠绿
        Color(red: 0.00, green: 0.68, blue: 0.71),  // Teal / 青绿

        // 橙色系 - 活力、友好
        // Orange series - Energetic, friendly
        Color(red: 1.00, green: 0.60, blue: 0.00),  // Vibrant Orange / 活力橙
        Color(red: 1.00, green: 0.58, blue: 0.36),  // Coral / 珊瑚橙
        Color(red: 0.96, green: 0.49, blue: 0.00),  // Deep Orange / 深橙

        // 粉色系 - 温柔、现代
        // Pink series - Gentle, modern
        Color(red: 0.91, green: 0.12, blue: 0.39),  // Hot Pink / 热粉
        Color(red: 0.96, green: 0.26, blue: 0.52),  // Rose / 玫瑰粉
        Color(red: 0.94, green: 0.38, blue: 0.57),  // Soft Pink / 柔粉

        // 红色系 - 重要、激情
        // Red series - Important, passionate
        Color(red: 0.96, green: 0.26, blue: 0.21),  // Material Red / 材料红
        Color(red: 0.91, green: 0.30, blue: 0.24),  // Warm Red / 暖红

        // 青色系 - 清爽、科技
        // Cyan series - Refreshing, technological
        Color(red: 0.00, green: 0.74, blue: 0.83),  // Cyan / 青色
        Color(red: 0.00, green: 0.64, blue: 0.73),  // Ocean Blue / 海洋蓝
    ]

    // MARK: - Random Color / 随机颜色

    /**
     * 获取随机的美观颜色
     *
     * Get a random beautiful color
     *
     * 从预定义的颜色集合中随机返回一个颜色，确保每次都是美观且和谐的。
     *
     * Returns a random color from the predefined color collection, ensuring it's always beautiful and harmonious.
     */
    static var random: Color {
        beautifulColors.randomElement() ?? .blue
    }

    /**
     * 获取指定数量的不重复随机颜色
     *
     * Get specified number of unique random colors
     *
     * 当需要多个不同的颜色时使用，例如创建图表或多个卡片。
     *
     * Use when you need multiple different colors, for example when creating charts or multiple cards.
     */
    static func randomColors(count: Int) -> [Color] {
        guard count > 0 else { return [] }

        var colors: [Color] = []
        var availableColors = beautifulColors.shuffled()

        for _ in 0..<count {
            if availableColors.isEmpty {
                availableColors = beautifulColors.shuffled()
            }
            colors.append(availableColors.removeFirst())
        }

        return colors
    }

    // MARK: - Gradient Colors / 渐变颜色

    /**
     * 获取随机的渐变色组合
     *
     * Get random gradient color combination
     *
     * 返回两个相配的颜色，适合创建渐变效果。
     *
     * Returns two matching colors suitable for creating gradient effects.
     */
    static var randomGradient: [Color] {
        let gradientPairs: [([Color])] = [
            [Color(red: 0.00, green: 0.48, blue: 1.00), Color(red: 0.00, green: 0.60, blue: 0.86)],  // Blue gradient / 蓝色渐变
            [Color(red: 0.58, green: 0.44, blue: 0.86), Color(red: 0.69, green: 0.32, blue: 0.87)],  // Purple gradient / 紫色渐变
            [Color(red: 0.30, green: 0.69, blue: 0.31), Color(red: 0.18, green: 0.80, blue: 0.44)],  // Green gradient / 绿色渐变
            [Color(red: 1.00, green: 0.60, blue: 0.00), Color(red: 1.00, green: 0.58, blue: 0.36)],  // Orange gradient / 橙色渐变
            [Color(red: 0.91, green: 0.12, blue: 0.39), Color(red: 0.96, green: 0.26, blue: 0.52)],  // Pink gradient / 粉色渐变
            [Color(red: 0.00, green: 0.74, blue: 0.83), Color(red: 0.00, green: 0.64, blue: 0.73)],  // Cyan gradient / 青色渐变
        ]

        return gradientPairs.randomElement() ?? [.blue, .purple]
    }

    // MARK: - Semantic Colors / 语义颜色

    /**
     * 语义化的随机颜色 - 根据用途返回合适的颜色
     *
     * Semantic random colors - Returns appropriate colors based on usage
     *
     * 这些颜色组合经过精心设计，适合特定的使用场景。
     *
     * These color combinations are carefully designed for specific use cases.
     */

    /// 适合卡片背景的柔和颜色 / Soft colors suitable for card backgrounds
    static var randomCardColor: Color {
        let cardColors: [Color] = [
            Color(red: 0.94, green: 0.95, blue: 1.00),  // Light Blue / 浅蓝
            Color(red: 0.95, green: 0.94, blue: 1.00),  // Light Purple / 浅紫
            Color(red: 0.94, green: 1.00, blue: 0.94),  // Light Green / 浅绿
            Color(red: 1.00, green: 0.96, blue: 0.94),  // Light Orange / 浅橙
            Color(red: 1.00, green: 0.94, blue: 0.96),  // Light Pink / 浅粉
        ]
        return cardColors.randomElement() ?? Color.gray.opacity(0.1)
    }

    /// 适合强调的鲜艳颜色 / Vibrant colors suitable for emphasis
    static var randomAccentColor: Color {
        let accentColors: [Color] = [
            Color(red: 0.00, green: 0.48, blue: 1.00),  // Bright Blue / 明亮蓝
            Color(red: 0.69, green: 0.32, blue: 0.87),  // Royal Purple / 皇家紫
            Color(red: 0.18, green: 0.80, blue: 0.44),  // Emerald / 翡翠绿
            Color(red: 1.00, green: 0.60, blue: 0.00),  // Vibrant Orange / 活力橙
            Color(red: 0.91, green: 0.12, blue: 0.39),  // Hot Pink / 热粉
        ]
        return accentColors.randomElement() ?? .blue
    }
}

// MARK: - Preview Helper / 预览辅助

/**
 * 颜色预览视图 - 用于在预览中展示所有颜色
 *
 * Color preview view - Used to display all colors in preview
 */
struct ColorPaletteView: View {
    let columns = [
        GridItem(.adaptive(minimum: 80))
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Beautiful Colors Palette / 美观配色板")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.horizontal)

                LazyVGrid(columns: columns, spacing: 15) {
                    ForEach(Array(Color.beautifulColors.enumerated()), id: \.offset) { index, color in
                        RoundedRectangle(cornerRadius: 10)
                            .fill(color)
                            .frame(height: 80)
                            .overlay(
                                Text("\(index + 1)")
                                    .foregroundColor(.white)
                                    .fontWeight(.bold)
                            )
                    }
                }
                .padding(.horizontal)

                Text("Random Gradient Examples / 随机渐变示例")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .padding(.horizontal)
                    .padding(.top)

                ForEach(0..<6) { _ in
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            LinearGradient(
                                colors: Color.randomGradient,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 60)
                        .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
    }
}

// MARK: - Preview / 预览

#Preview("Color Palette") {
    ColorPaletteView()
}
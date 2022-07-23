export type Root = Frame & {
    ItemSwitchLister: {
        UIListLayout: UIListLayout,
        PrimaryButton: Frame & {
            Button: TextButton,
            SelectedFrame: Frame
        },

        SecondaryButton: Frame & {
            Button: TextButton,
            SelectedFrame: Frame
        },

        GadgetButton: Frame & {
            Button: TextButton,
            SelectedFrame: Frame
        },

        SkillButton: Frame & {
            Button: TextButton,
            SelectedFrame: Frame
        },
    },

    ItemInfo: Frame & {
        Top: Frame & {
            ItemName: TextLabel,
            RarityName: TextLabel,
            BG: Frame & {
                EquipButton: Frame & {
                    Button: TextLabel,
                    Icon: ImageLabel,
                    ButtonName: TextLabel
                },
            },
            RarityColor: Frame
        },
        Stats: Frame & {
            CoreStats: Frame & {
                Damage: Frame & {
                    StatName: TextLabel,
                    StatValue: TextLabel
                },
                FireRate: Frame & {
                    StatName: TextLabel,
                    StatValue: TextLabel
                },
                HeatRate: Frame & {
                    StatName: TextLabel,
                    StatValue: TextLabel
                }
            }
        },
        Buttons: {
            AchievementsButton: Frame & {
                Button: TextLabel,
                Icon: ImageLabel,
                ButtonName: TextLabel
            },
            CustomizeButton: Frame & {
                Button: TextLabel,
                Icon: ImageLabel,
                ButtonName: TextLabel
            }
        },
        BarStats: Frame & {
            UIListLayout: UIListLayout
        },
    },

    ItemDisplay: Frame & {
        Title: TextLabel,
        ScrollingFrame: ScrollingFrame & {
            Container: Frame & {
                UIListLayout: UIListLayout,
                UIPadding: UIPadding,
            }
        }
    },

    Search: Frame & {
        Icon: ImageLabel,
        Search: TextBox
    }
}

return nil
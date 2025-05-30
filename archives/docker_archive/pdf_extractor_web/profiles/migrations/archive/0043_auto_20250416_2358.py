# Generated by Django 5.2 on 2025-04-16 23:58

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ("profiles", "0042_add_payee_reasoning"),
    ]

    operations = [
        migrations.AddField(
            model_name="transaction",
            name="business_percentage",
            field=models.IntegerField(default=100, null=True, blank=True),
        ),
        migrations.AddField(
            model_name="transaction",
            name="classification_type",
            field=models.CharField(max_length=50, null=True, blank=True),
        ),
        migrations.AddField(
            model_name="transaction",
            name="worksheet",
            field=models.CharField(max_length=50, null=True, blank=True),
        ),
        migrations.AlterField(
            model_name="transaction",
            name="classification_method",
            field=models.CharField(
                max_length=20,
                choices=[
                    ("AI", "AI Classification"),
                    ("Human", "Human Override"),
                    ("None", "Not Processed"),
                ],
                default=None,
                null=True,
                blank=True,
            ),
        ),
        migrations.AlterField(
            model_name="transaction",
            name="payee_extraction_method",
            field=models.CharField(
                max_length=20,
                choices=[
                    ("AI", "AI Only"),
                    ("AI+Search", "AI with Search"),
                    ("Human", "Human Override"),
                    ("None", "Not Processed"),
                ],
                default=None,
                null=True,
                blank=True,
            ),
        ),
    ]
